#ifndef UTILS_H
#define UTILS_H

#include <iostream>
#include <fstream>
#include <codecvt>
#include <string.h>
#include <sstream>
#include <wchar.h>
#include <locale>
#include <iomanip>
#include <vector>
#include <chrono>
#include <malloc.h>
#include <stdio.h>
#include <math.h>

// XRT includes
#include "xrt/xrt_bo.h"
#include <experimental/xrt_xclbin.h>
#include "xrt/xrt_device.h"
#include "xrt/xrt_kernel.h"
#include <experimental/xrt_ip.h>

#include "tsp.h"

#define SIZE_256M 256*1024*1024
#define SIZE_4M 4*1024*1024
#define SIZE_128K 128*1024
#define SIZE_64K 64*1024
#define SIZE_32K 32*1024
#define SIZE_1K 1024
#define SIZE_4K 4*1024
#define SIZE_2K 2*1024
#define SIZE_128B 128
#define NUM_KRNL 32

// uint32_t KRNL_SIZE = SIZE_4K;
// uint32_t BO_SIZE = KRNL_SIZE/32;
#define BO_SIZE SIZE_256M
#define KRNL_SIZE SIZE_32K
#define BATCH_SIZE SIZE_1K

#define CMP_JP_DIGIT_UNIC(x) ((x[0] ==(signed char)0xef)&(x[1] ==(signed char)0xbc) & (x[2] >=(signed char)0x90) &(x[2] <=(signed char)0x99))
#define CMP_JP_DIGIT_SJIS(x) (x[0] ==(signed char)0x82) & ((x[1] >= (signed char)0x4f) & (x[1] <= (signed char)0x58))
#define CMP_ZERO_1(x) (x[0]== (signed char)0x30) //compare with 0 in ENG
#define CMP_MASK_1(x) (x[0]== (signed char)0x3f) //compare with ? in ENG
#define CMP_GAP_1(x)  (x[0]== (signed char)0x5f) //compare with _ in ENG
#define CMP_MASK_2(x) ((x[0]== (signed char)0x81) & (x[1]== (signed char)0x48)) //compare with ？ in JP SJIS
#define CMP_GAP_2(x)  ((x[0]== (signed char)0x81) & (x[1]== (signed char)0x51)) //compare with ＿ in JP SJIS
#define CMP_MASK_3(x) ((x[0]== (signed char)0xef) & (x[1]== (signed char)0xbc) & (x[2]== (signed char)0x9f)) //compare with ？ in JP Unicode
#define CMP_GAP_3(x)  ((x[0]== (signed char)0xef) & (x[1]== (signed char)0xbc) & (x[2]== (signed char)0xbf)) //compare with ＿ in JP Unicode

#define HEX( x )  (0xFF & x)

extern bool andSearch;
extern bool orSearch;
extern uint32_t language;
extern double total_search_time;
extern uint32_t outputMode; //0: Address, 1: Bitstream, 2: Hit

extern std::string root;
extern std::string result_summary;
extern std::string result_hit;
extern std::string config;


class keyWord{
    //public
    public:
        //variables
        std::string key;
        uint32_t type;
        uint32_t hitTime;
        double timeSearch;
        double timeReadFIFO;
        std::vector<uint32_t> hitAddr;
        bool useWildCard;
       
        //utilities
        bool kand;


        //constructor 1
        keyWord(){
            key = "";
            type = 0;
            hitTime = 0;
            timeSearch=0;
            timeReadFIFO=0;
            useWildCard = false;
            kand=false;
        }
        //constructor 2
        keyWord(std::string s, int i, uint32_t wc, uint32_t keyand){
            key = s;
            type = i;
            hitTime = 0;
            timeSearch=0;
            timeReadFIFO=0;
            useWildCard = wc;
            kand = keyand;
        }

        void update_hitTime(){
            hitTime = hitAddr.size();
        }

        void printHitAddr(){
            std::cout<<"Hit addr: ";
            for(size_t i = 0; i<hitAddr.size();i++){
                std::cout<<hitAddr[i]<<"   ";
            }
            std::cout<<std::endl;
        }
};

class searchFile{
    public:
    std::string name;
    std::string text;
    size_t textSize;
    double sync_time; //old version
    uint32_t memTracker; //tracking max memory of a channels that stores text data  //old version
    uint32_t batchNum; //old version

    std::vector<bool> foundKey;
    // std::vector<bool> andKey; //no need
    std::vector<keyWord> keyList;
    size_t keyListSize;

    //constructor 1
    searchFile(){
        text = "";
        sync_time = 0;
        memTracker = 0;
        batchNum = 0;
    }

    //constructor 2
    searchFile(std::string textPath, std::vector<keyWord> keys){
        text = textPath;
        int pos = textPath.find_last_of('/');
        name = textPath.substr(pos+1);
        updateFileSize();
        sync_time = 0;
        memTracker = 0;
        batchNum = 0;
        keyList = keys;
        keyListSize = keyList.size();
        for(size_t i=0; i<keyListSize; i++){
            foundKey.push_back(false);
            // andKey.push_back(false);
        }
    }

    //constructor 3
    searchFile(std::string textPath){
        text = textPath;
        int pos = textPath.find_last_of('/');
        name = textPath.substr(pos+1);
        updateFileSize();
        sync_time = 0;
        memTracker = 0;
        batchNum = 0;
    }

    void updateFileSize(){
        std::ifstream file(text, std::ios::binary); //read file
        if(!file.is_open()){
            std::cout<<"Error read file["<<name<<"]"<<std::endl;
            exit(EXIT_FAILURE);
        }
        file.seekg(0,std::ios::end); //move the read cursor to the end
        textSize = file.tellg(); //get the file size
        file.close();
    }

    void updateFoundKey(){
        for(size_t i=0;i<keyListSize;i++){
            if(keyList[i].hitTime != 0) foundKey[i] = true;
        }
    }

    void printContext(){
        std::cout<<"Text path: "<<text<<std::endl;
        std::vector<keyWord>::iterator it;
        for(it = keyList.begin(); it < keyList.end(); it++){
            std::cout<<"    Key: "<< it->key<<" - type: "<< it->type<<" - wildcard: "<< it->useWildCard << std::endl;
            std::cout<<"    Size: "<<textSize<<std::endl;
        }
    }

    void printFoundKey(){
        std::cout<<"Text path: "<<text<<std::endl;
        std::vector<keyWord>::iterator it;
        int i = 0;
        for(it = keyList.begin(); it < keyList.end(); it++){
            std::cout<<"    Key: "<< it->key<<" - found: "<< foundKey[i]<< std::endl;
            keyList[i].printHitAddr();
            i++;
        }
    }
};


std::vector<std::string> readTextList(std::string path);
std::vector<keyWord> readKeyWord(std::string path);

uint32_t round8(uint32_t fileSize);
uint32_t writeHBM(std::vector<searchFile>* fileList, char* mem[NUM_KRNL]);
uint32_t writeHBM_padding(std::vector<searchFile>* fileList, char* mem[NUM_KRNL]);
size_t preprocessText(searchFile* fileToSeach, char* mem[NUM_KRNL]);

//TSP control
void tsp_write_address(xrt::ip krnl, std::vector<xrt::bo> bo,  uint32_t addrInBytes, uint32_t batch_cnt);
uint32_t get_num_jp_unicode(std::string str, size_t s);
uint32_t get_num_jp_sjis(std::string str, size_t s);
std::string string_to_hex(const std::string& input);
int tsp_write_all_key(xrt::ip krnl, std::vector<keyWord> *keyList);
int tsp_write_key(xrt::ip krnl, keyWord* key, bool last);
uint32_t waitSignal(xrt::ip krnl, uint32_t base, uint32_t offset);


void postProcessResult(std::vector<searchFile>* listFile, std::vector<keyWord>* keyList);
void exportResult(std::vector<searchFile> listFile, std::vector<keyWord> listKey, uint64_t total_size, double totalTimeSearch, uint32_t batch);
void printResult(std::vector<searchFile> listFile, uint64_t total_size, double totalTimeSearch, uint32_t batch);
void exportHit(std::vector<searchFile> listFile, uint64_t total_size, double totalTimeSearch, uint32_t batch);
void exportHitAddress(std::vector<searchFile> listFile);
void exportDummy();
std::string getTime(double time);
std::string getByte(uint32_t byte);

#endif //UTILS_H
