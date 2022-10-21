#include "utils.h"
#include <iostream>
#include <cstring>

// #define DEBUG_FILE_CONTEXT

bool andSearch = false;
bool orSearch = false;
uint32_t language = 0;

std::string root = "/Desktop/TSP.temp/";
std::string result_summary = "result.summary/";
std::string result_hit = "result.hit/";
std::string config = "config/";
// std::string userPath;

void exportLoadSummary(uint32_t total_written_size,double transferTime, uint32_t batch_count){
    std::stringstream ss;
    ss <<root+config+"loadSummary.csv";
    
    std::string fileName = ss.str();
    std::ofstream  oFile(fileName);
    oFile<<total_written_size<<","<< transferTime <<","<<batch_count<<",";
    oFile.close();
}

int main(int argc, char** argv) {

    std::cout<<std::endl<<"TSP PROGRAM FPGA AND LOAD TEXT TO HBM\n"<<std::endl;
    //===============================================================//
    //-----------------------PROCESSING ARGUMENT---------------------//
    //===============================================================//
    if (argc != 8) {
        printf("Usage: %s <XCLBIN> <textListPath> <keyWordPath> <language> <searchMode> <outputMode> <userpath>\n", argv[0]);
        return -1;
    }
    std::string binaryFile = argv[1];
    std::string textListPath = argv[2];
    std::string keyWordPath = argv[3];
    language = std::atoi(argv[4]);
    std::string searchMode = argv[5];
    std::string userPath = argv[7];
    root = userPath + root;

    //Read text list
    std::vector<std::string> textList = readTextList(textListPath);

    //Todo: may not need to do this
    //Read key words
    // std::vector<keyWord> keyWords = readKeyWord(keyWordPath);

    //listFile conaints all file, keywords and corresponding search results
    std::vector<searchFile> listFile;
    for(size_t i = 0; i<textList.size(); i++){
        listFile.push_back(searchFile(textList[i]));
        //#define DEBUG_FILE_CONTEXT
        #ifdef DEBUG_FILE_CONTEXT
            listFile[i].printContext();
        #endif //DEBUG_FILE_CONTEXT
    }

    //======================================================================//
    //---------------------------TSP SETUP ALVEO----------------------------//
    //======================================================================//

    //Open device
    int device_index = 0;
    std::cout << "Open the device" << device_index << std::endl;
    auto device = xrt::device(device_index);
    std::cout << "Load the xclbin " << binaryFile << std::endl;
    auto uuid = device.load_xclbin(binaryFile); // Load bitstream
    // std::cout<< "UUID: "<<uuid.to_string()<<std::endl;

    //set up kernel
    std::string kernel_name_full = "krnl_tsp_rtl:{krnl_tsp_rtl_1}";
    auto kernel = xrt::ip(device, uuid, kernel_name_full.c_str()); //create 1 kernel with 32 channels

    //Allocate global memory on HBM
    //Allocate bo
    std::vector<xrt::bo> bo;
    std::cout << "Allocate Buffer in Global Memory...";
    for(int k=0; k<NUM_KRNL;k++){
        auto temp = xrt::bo(device, SIZE_256M, k); //alloc 64KB in each bo => get process a file with max size = 32*64KB
        bo.push_back(temp);
    }
    std::cout<<"PASSED\n";

    //Map bo memory to PC => we can use the mapped memory on PC as normal pointer, then do a sync to transfer to FPGA
    std::cout << "Map Global memory to host PC...";
    char* mem_ptr[NUM_KRNL];
    for(int i =0;i<NUM_KRNL;i++){
        mem_ptr[i] = bo[i].map<char*>();
        // std::fill(mem_ptr[i], mem_ptr[i]+BO_SIZE, 0); //reset memory to 0
    }
    std::cout<<"PASSED\n";

    //======================================================================//
    //---------------------------LOAD DATA TO HBM---------------------------//
    //======================================================================//

    //==========================Step 1: Write to HBM========================//
    /** This test write all files in to HBM
     *  All files have total size <= 8GB
     *  Files are concatenated with padding and written to HBM
     */
    std::cout<<"====================Step 1: Write to HBM====================\n";

    uint32_t total_written_size = writeHBM_padding(&listFile, mem_ptr);
    // if(total_written_size >= 1024*1024*1024){
    //     std::cout<<"Total written bytes: "<<(float)total_written_size/(1024*1024*1024)<<" GB"<<std::endl;
    // }else if(total_written_size >= 1024*1024){
    //     std::cout<<"Total written bytes: "<<(float)total_written_size/(1024*1024)<<" MB"<<std::endl;
    // }else if(total_written_size >= 1024){
    //     std::cout<<"Total written bytes: "<<(float)total_written_size/(1024)<<" KB"<<std::endl;
    // }else{
    //     std::cout<<"Total written bytes: "<<total_written_size<<" bytes"<<std::endl;
    // }
    std::cout<<"Total written bytes: "<<getByte(total_written_size)<<std::endl;
    
    std::cout<<"Total bo rounds: "<<(float)total_written_size/(BATCH_SIZE)<<std::endl;
    uint32_t batch_count = ceil((float)total_written_size/(KRNL_SIZE));
    std::cout<<"Total batch: "<<(float)total_written_size/(KRNL_SIZE) <<" - batch count: "<< ceil((float)total_written_size/(KRNL_SIZE)) <<std::endl;
    // std::cout<<"Batch count: "<<batch_count<<std::endl;

    //Load data to HBM
    std::cout<<"Load text to HBM memory...\n";
    // Synchronize buffer content with device side
    std::chrono::duration<double> transfer_time(0);
    auto transfer_start = std::chrono::high_resolution_clock::now();
    for(int k=0; k<NUM_KRNL;k++){
        bo[k].sync(XCL_BO_SYNC_BO_TO_DEVICE, /*size*/batch_count*BATCH_SIZE, /*offset*/0);
    }
    auto transfer_end = std::chrono::high_resolution_clock::now();
    transfer_time = std::chrono::duration<double>(transfer_end - transfer_start);
    std::cout<<"Sync data time: "<<getTime(transfer_time.count())<<std::endl;
    
    // Write initial address for the first time
	kernel.write_register(START_ADDRESS + 4, bo[0].address() >> 32);
	kernel.write_register(START_ADDRESS, bo[0].address() + 0);

    exportLoadSummary(total_written_size, transfer_time.count(), batch_count);
    exportDummy();
    std::cout<<"Load files to HBM completed\n";
    return 0;
}
