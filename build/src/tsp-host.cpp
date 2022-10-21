#include "utils.h"
#include <iostream>
#include <cstring>
#include <bitset>
#include <signal.h>

#define NUM_KRNL 32
#define SIZE_128K 128*1024

bool andSearch = false;
bool orSearch = false;
uint32_t language = 0;
uint32_t outputMode = 0;

double total_search_time = 0;
uint64_t total_written_size = 0;
uint32_t batch_count = 0;
bool timeCapture = false;
std::chrono::duration<double> search_key_time(0);
std::chrono::_V2::system_clock::time_point search_start;
std::chrono::_V2::system_clock::time_point search_end;

// uint32_t total_hit = 0;
std::string root = "/Desktop/TSP.temp/";
std::string result_summary = "result.summary/";
std::string result_hit = "result.hit/";
std::string config = "config/";


void readLoadSummary(std::string path, uint64_t &total_written_size, uint32_t &batch_count){
    // File pointer
    std::ifstream inFile(path);
    std::string line;

    if(inFile.is_open()){
        std::getline(inFile, line);
        std::stringstream ss(line);
        std::string size, time, batch;

        std::getline(ss,size,',');
        std::getline(ss,time,',');
        std::getline(ss,batch,',');
        total_written_size = stol(size);
        batch_count = stoi(batch);
    }else{
        std::cout<<"Can not load summary file\n";
        exit(EXIT_FAILURE);
    }

    inFile.close();
}

int main(int argc, char** argv) {

    std::cout<<std::endl<<"TEXT SEARCH PROCESSOR PROGRAM\n"<<std::endl;

     
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
    std::string output = argv[6];
    std::string userPath = argv[7];
    root = userPath + root;

    if(searchMode.compare("OR") == 0){
        orSearch = true;
        std::cout<<"Search Mode: OR search"<<std::endl;
    }else if(searchMode.compare("AND") == 0){
        andSearch = true;
        std::cout<<"Search Mode: AND search"<<std::endl;
    }

    if(output.compare("Address") == 0){
        outputMode = 0;
        std::cout<<"Output Mode: Address"<<std::endl;
    }else if(output.compare("Hit") == 0){
        outputMode = 1;
        std::cout<<"Output Mode: Hit"<<std::endl;
    }

    //Read text list
    std::vector<std::string> textList = readTextList(textListPath);
    //Read key words
    std::vector<keyWord> keyWords = readKeyWord(keyWordPath);
    
    //listFile conaints all file, keywords and corresponding search results
    std::vector<searchFile> listFile;
    for(size_t i = 0; i<textList.size(); i++){
        listFile.push_back(searchFile(textList[i],keyWords));
        // #define DEBUG_FILE_CONTEXT
        #ifdef DEBUG_FILE_CONTEXT
            if(listFile[i].text.find("/home/tuankiet/Desktop/EN_text/") != std::string::npos){
                listFile[i].printContext();
            }
        #endif //DEBUG_FILE_CONTEXT
    }

    readLoadSummary(root + config + "loadSummary.csv",total_written_size, batch_count);

    //===========================================================//
    //-----------------------TSP SETUP ALVEO---------------------//
    //===========================================================//
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
    kernel.write_register(DEV_CTRL, TSP_DEV_CTRL_RESET);

    // Write initial address for the first time
	kernel.write_register(START_ADDRESS + 4, 0);
	kernel.write_register(START_ADDRESS, 0);

    //======================================================================//
    //---------------------------SEARCH START HERE---------------------------//
    //======================================================================//
    int status = 0;

    //====================Step 2: Loop over keys for each file ====================//
    std::cout<<"===========Step 2: Write all keys to kernel ===========\n";

    kernel.write_register(DEV_CTRL, DEV_CONTINUE);
    // kernel.write_register(DEV_CTRL, TSP_DEV_CTRL_RESET);
    status =  tsp_write_all_key(kernel, &keyWords);
    if(status == -1) {
        std::cout<<"Error setting keys\n";
        exit(1);
    }

    //====================Step 3: Loop over keys for each file ====================//
    std::cout<<"===========Step 3: Loop over keys for each file ===========\n";
    uint32_t read_data = 0;
    uint64_t bashOffset = 0;
    size_t keyNum = listFile[0].keyListSize;

    //loop over files
    for(size_t fIndex = 0; fIndex < listFile.size(); fIndex++){
        // Update file size for the begin of file
        // std::cout<<"Search file #"<<fIndex<<" - with size "<<listFile[fIndex].textSize<<" Bytes - "<<round8(listFile[fIndex].textSize) <<" Bytes\n";
        kernel.write_register(FILE_SIZE, round8(listFile[fIndex].textSize));
        int64_t nextFileSize = 0;
        nextFileSize = listFile[fIndex].textSize;

        //loop all batches in files if file_size > BATCH_SIZE
        while(nextFileSize > 0){
            // Load text
			kernel.write_register(DEV_CTRL, DEV_LOADTEXT);
            status = waitSignal(kernel, CTRL, LOAD_DONE_MASK);
            if(status == -1) {
                std::cout<<"Error wait load text\n";
                exit(1);
            }

            // std::ofstream oFile;
            // if(outputMode == 1){
            //     std::string fName = root + result_bit + "bitstream_" + listFile[fIndex].name;
            //     oFile.open(fName, std::ofstream::out | std::ofstream::app);
            // }

            // std::cout<<"|   ===========Step 4: Loop over keys to read result ===========\n";
            for(size_t kIndex = 0; kIndex < keyNum; kIndex++){
                //Start device
                // std::cout << "|   Start device..." << std::endl;
                if((outputMode == 1) && (listFile[fIndex].foundKey[kIndex] == true)){continue;} //if output Hit Mode, check if already hit or not
                
                read_data = kernel.read_register(DEV_CTRL);
                // std::cout<<"|   Read register: "<<read_data<<std::endl;
                
                kernel.write_register(DEV_CTRL, TSP_DEV_CTRL_START | read_data);
                //if (kIndex == 0) continue;
                if(timeCapture == false){
                    timeCapture = true;
                    search_start = std::chrono::high_resolution_clock::now();
                }

                read_data = kernel.read_register(CTRL);
                if((read_data & DEV_DONE) != DEV_DONE){
                    // Polling finish
                    status = waitSignal(kernel, CTRL, DEV_DONE);
                    if(status == -1) {
                    std::cout<<"|   Error wait finish\n";
                    exit(1);
                    }
                }
                
                // std::cout<<"search time: "<<search_key_time.count()<<"sec"<<std::endl;
                // read_data = kernel.read_register(CTRL);
                // std::cout<<"done: "<<std::hex<<read_data<<std::endl;

                //#define DEBUG_BATCH
                #ifdef DEBUG_BATCH
                    if(listFile[fIndex].name.compare("770-0.txt") == 0){
                        
                        uint32_t bashCode = 0;
                        std::cout << "|   Search complete..." << std::endl;
                        // Read address result
                        std::cout << "|   Read address result..." << std::endl;
                        bashCode = kernel.read_register(BASHCODE);
                        std::cout << "|   Bash code: " << bashCode << std::endl;
                        read_data = kernel.read_register(BASH_OFFSET + 4);
                        bashOffset = read_data;
                        read_data = kernel.read_register(BASH_OFFSET);
                        bashOffset = (bashOffset << 32) + read_data;
                        std::cout << "|   Bash offset: " << bashOffset << std::endl;
                    }
                #endif //DEBUG_BATCH
                

                //--Read results
                do{ //outputMode != Bitstream
                    read_data = kernel.read_register(RESULT);
                    // if( (read_data>>15) & 1){ // >= 65536
                        read_data = read_data & (~(1<<16)); // read_data = read_data - 65536;
                        if (read_data != 65535) {
                            if(outputMode == 1){ //if outputMode = Hit
                                //if (kIndex == 0) listFile[fIndex].foundKey[kIndex] = false;
                                //else listFile[fIndex].foundKey[kIndex] = true;
                                listFile[fIndex].foundKey[kIndex] = true;
                                break; //dont need to save hit address, break loop
                            }else{
                                //if (kIndex != 0) {
                                    read_data = bashOffset + read_data; //final address
                                    listFile[fIndex].keyList[kIndex].hitAddr.push_back(read_data);
                                //}
                                // std::cout << "|   Result: " << read_data << std::endl;
                            }
                        }
                    // }
                }while(read_data != 65535);


                // switch (outputMode)
                // {
                // case 0: //Address
                //     //--Read results
                //     do{ //outputMode != Bitstream
                //         read_data = kernel.read_register(RESULT);
                //         // if( (read_data>>15) & 1){ // >= 65536
                //             read_data = read_data & (~(1<<16)); // read_data = read_data - 65536;
                //             if (read_data != 65535) {
                //                     read_data = bashOffset + read_data; //final address
                //                     listFile[fIndex].keyList[kIndex].hitAddr.push_back(read_data);
                //                     // std::cout << "|   Result: " << read_data << std::endl;
                //             }
                //         // }
                //     }while(read_data != 65535);
                //     break;
                // case 1: //Bitstream
                //     for(uint32_t loop = 0; loop<1024; loop++){
                //         std::string temp ="";
                //         read_data = kernel.read_register(BITSTREAM);
                //         temp = std::bitset<32>(read_data).to_string();
                //         oFile<<temp;
                //     }
                //     break;
                // case 2: //Hit
                //     //--Read results
                //     do{ //outputMode != Bitstream
                //         read_data = kernel.read_register(RESULT);
                //         read_data = read_data & (~(1<<16)); // read_data = read_data - 65536;
                //         if (read_data != 65535) {
                //             listFile[fIndex].foundKey[kIndex] = true;
                //             break; //dont need to save hit address, break loop
                //         }
                //     }while(read_data != 65535);
                //     break;
                // default:
                //     std::cout<<"Non-specified mode\n";
                //     exit(EXIT_FAILURE);
                //     break;
                // }


                // total_hit += kernel.read_register(MATCH_COUNT);
	            // std::cout << "Match count: " << read_data << std::endl;

                if(outputMode == 0){
                    listFile[fIndex].keyList[kIndex].update_hitTime(); //update total #hit of a key
                }
            } //end for loop keys

            if(outputMode == 0){
                listFile[fIndex].updateFoundKey(); //update hit key status 
            }

            // Read remain file size
			read_data = kernel.read_register(NEXT_FILESIZE + 4);
			nextFileSize = read_data;
			read_data = kernel.read_register(NEXT_FILESIZE);
			nextFileSize = (nextFileSize << 32) + (uint64_t)read_data;

            // #define DEBUG_FILE_SIZE
            #ifdef DEBUG_FILE_SIZE
                if(nextFileSize > 0){
                    std::cout << "Remain file size: " <<std::dec<< nextFileSize << " Bytes - Continue with same file" << std::endl;
                }else{
                    std::cout << "File search complete - Search next file\n";
                }
            #endif //DEBUG_FILE_SIZE
        } //end while nextFileSize
    } //end for loop files

    search_end = std::chrono::high_resolution_clock::now();
    search_key_time = std::chrono::duration<double>(search_end - search_start);
    total_search_time += search_key_time.count();

    std::cout<<"Exporting output...\n";
    // printResult(listFile,total_written_size,total_search_time,batch_count);
    for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
        listFile[fIndex].keyList.erase(listFile[fIndex].keyList.begin());
        listFile[fIndex].foundKey.erase(listFile[fIndex].foundKey.begin());
        listFile[fIndex].keyListSize -= 1; 
    }

    keyWords.erase(keyWords.begin());

    if(outputMode == 0){ //Address
        exportResult(listFile,keyWords,total_written_size,total_search_time,batch_count);
        exportHitAddress(listFile);
    }else if(outputMode == 1){ //Hit
        exportHit(listFile,total_written_size,total_search_time,batch_count);
    }
    // std::cout<<"total hit: "<<std::dec<<total_hit<<std::endl;

    exportDummy();
    std::cout<<"Program finished\n";
    
    kill(getpid(),SIGINT);
    return 0;
}
