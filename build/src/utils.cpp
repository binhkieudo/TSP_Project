#include "utils.h"

// #define DEBUG_KEY
// std::string root;
// std::string result_summary;
// std::string result_hit;
// std::string config;

std::vector<std::string> readTextList(std::string path){
    std::ifstream inFile(path);
    std::vector<std::string> textList;
    std::string fileName;
    if(inFile.is_open()){
        while(inFile >> fileName){
            textList.push_back(fileName);
        }
    }else{
        std::cout<<"Can not read text list file\n";
        exit(EXIT_FAILURE);
    }

    inFile.close();
    return textList;
};

std::vector<keyWord> readKeyWord(std::string path){
    //return vector
    std::vector<keyWord> keyVec;
    // File pointer
    std::ifstream inFile(path);
    std::string line;

    int keyCount = 0;
    if(inFile.is_open()){
        while(std::getline(inFile, line)){
            std::stringstream ss(line);

            std::string key, type, wildcard, keyand;
            uint32_t wc = 0;
            uint32_t kand = 0;
            int type_int;
            std::string t = "true";

            std::getline(ss,key,',');
            std::getline(ss,type,',');
            std::getline(ss,wildcard,',');
            std::getline(ss,keyand,',');
            type_int = stoi(type);

            if(wildcard.compare(t)==0){
                wc = 1;
            }
            if(keyand.compare(t)==0){
                kand = 1;
            }
            keyWord temp(key, type_int, wc, kand);

            if (keyCount == 0) {
                keyCount++;
                std::string keytmp2 = "000000";
                keyWord temp2(keytmp2, type_int, 0, 0);
                keyVec.push_back(temp2);
            }

            keyVec.push_back(temp);
        }
    }else{
        std::cout<<"Can not read key list file\n";
        exit(EXIT_FAILURE);
    }

    inFile.close();
    return keyVec;
}

/**
 * @brief: read all files in the list and write to HBM
 * Write process:
 *  - Create a buffer to store 1 file
 *  - Copy one-by-one byte from the buffer to mapped bo
 * This is a stupid writing to HBM, but the requirement is HBM has to be full of text with out padding between each files
*/

uint32_t writeHBM(std::vector<searchFile>* fileList, char* mem[NUM_KRNL]){
    uint32_t batch_tracker = 0; //use to track current batch to write; total number of batch = BO_SIZE/BATCH_SIZE
    uint32_t bo_tracker = 0; //use to track current writing bo
    int addr_tracker = BATCH_SIZE-1; //use to track current address to write in bo (byte adressing), write from top down to 0
    int byte_tracker = 7;
    uint32_t total_written_byte = 0;

    for(size_t fIndex = 0; fIndex<fileList->size(); fIndex++){
        searchFile & fileToWrite = fileList->at(fIndex); //get 1 file from list
        std::cout<<"---> Writing file["<<fileToWrite.name<<"]";
        std::ifstream file(fileToWrite.text, std::ios::binary); //read file
        if(!file.is_open()){
            std::cout<<"Error read file["<<fileToWrite.name<<"]"<<std::endl;
            exit(EXIT_FAILURE);
        }
        file.seekg(0,std::ios::end); //move the read cursor to the end
        fileToWrite.textSize = file.tellg(); //get the file size
        fileList->at(fIndex).textSize = fileToWrite.textSize;
        
        file.seekg(0); //reset to the beginning
        uint32_t text_remainder = fileToWrite.textSize;
        std::cout<<" with size "<<text_remainder<<" bytes...";
        std::cout<<"File size: "<<fileList->at(fIndex).textSize<<std::endl;
        //TODO: initialize bo with 0 for 1 batch
        char *buffer=new char[text_remainder]; //buffer whole file
        file.read(buffer,text_remainder);

        for(uint32_t b = 0; b < text_remainder; b++){
            *(mem[bo_tracker]+addr_tracker+batch_tracker*BATCH_SIZE-byte_tracker) = buffer[b]; //write each byte, instead of using memcpy
            byte_tracker--;
            if(byte_tracker<0){
                addr_tracker -= 8;
                byte_tracker = 7;
            }
            if(addr_tracker<0){//if write full 1 bo
                bo_tracker++; //go to the next one
                addr_tracker = BATCH_SIZE-1; //reset addr_tracker
            }
            if(bo_tracker == NUM_KRNL){ //if write to all NUM_KRNL
                batch_tracker += 1; // go to next batch
                bo_tracker = 0; // reset to bo[0]
            }
            total_written_byte++;
        }
        std::cout<<"DONE"<<std::endl;
        file.close();
    }

    return total_written_byte;
}

uint32_t round8(uint32_t fileSize){
    uint32_t num = 0;

    while(1){
        num += 8;
        if(num >= fileSize) break;
    }

    return num;
}

uint32_t writeHBM_padding(std::vector<searchFile>* fileList, char* mem[NUM_KRNL]){
    uint32_t batch_tracker = 0; //use to track current batch to write; total number of batch = BO_SIZE/BATCH_SIZE
    uint32_t bo_tracker = 0; //use to track current writing bo
    // int addr_tracker = BATCH_SIZE-8; //use to track current address to write in bo (byte adressing), write from top down to 0
    int addr_tracker = 0;
    // int byte_tracker = 7;
    uint32_t total_written_byte = 0;

    for(size_t fIndex = 0; fIndex<fileList->size(); fIndex++){
        searchFile & fileToWrite = fileList->at(fIndex); //get 1 file from list
        // std::cout<<"---> Writing file["<<fileToWrite.name<<"]";
        std::ifstream file(fileToWrite.text, std::ios::binary); //read file
        if(!file.is_open()){
            std::cout<<"Error read file["<<fileToWrite.name<<"]"<<std::endl;
            exit(EXIT_FAILURE);
        }
        // file.seekg(0,std::ios::end); //move the read cursor to the end
        // fileToWrite.textSize = file.tellg(); //get the file size

        // fileList->at(fIndex).textSize = fileToWrite.textSize; //???

        // if(fileToWrite.text.find("/home/tuankiet/Desktop/EN_text/") != std::string::npos){
        //     fileToWrite.printContext();
        //     std::cout<<"Recheck: "<< fileToWrite.textSize <<std::endl;
        // }



        file.seekg(0); //reset to the beginning
        int text_remainder = fileToWrite.textSize;
        // std::cout<<" with size "<<text_remainder<<" bytes...";
        // std::cout<<"File size: "<<fileList->at(fIndex).textSize<<std::endl;
        //TODO: initialize bo with 0 for 1 batch
        char *buffer=new char[text_remainder]; //buffer whole file
        file.read(buffer,text_remainder);

        // for(uint32_t b = 0; b < fileToWrite.textSize; b+=8){
        //     if(text_remainder <= 8){
        //         memcpy(mem[bo_tracker]+addr_tracker+batch_tracker*BATCH_SIZE, buffer+b, text_remainder);
        //         total_written_byte += text_remainder;
        //         text_remainder -= text_remainder;
        //     }else{
        //         memcpy(mem[bo_tracker]+addr_tracker+batch_tracker*BATCH_SIZE, buffer+b, 8);
        //         text_remainder -= 8;
        //         total_written_byte += 8;
        //     }
            
        //     addr_tracker -= 8;
        //     if(addr_tracker<0){//if write full 1 bo
        //         bo_tracker++; //go to the next one
        //         addr_tracker = BATCH_SIZE-8; //reset addr_tracker
        //     }
        //     if(bo_tracker == NUM_KRNL){ //if write to all NUM_KRNL
        //         batch_tracker += 1; // go to next batch
        //         bo_tracker = 0; // reset to bo[0]
        //     }
        //     //TODO: track the number of batch, if full 8GB, save the current "b" and file name for next writeHBM
        // }

        for(uint32_t b = 0; b < fileToWrite.textSize; b+=8){
            if(text_remainder <= 8){
                memcpy(mem[bo_tracker]+addr_tracker+batch_tracker*BATCH_SIZE, buffer+b, text_remainder);
                // std::cout<<"remainder: "<<text_remainder<<std::endl;
                total_written_byte += text_remainder;
                text_remainder -= text_remainder;
            }else{
                memcpy(mem[bo_tracker]+addr_tracker+batch_tracker*BATCH_SIZE, buffer+b, 8);
                text_remainder -= 8;
                total_written_byte += 8;
            }
            
            addr_tracker += 8;
            if(addr_tracker >(BATCH_SIZE-8)){//if write full 1 bo
                bo_tracker++; //go to the next one
                // addr_tracker = BATCH_SIZE-8; //reset addr_tracker
                addr_tracker = 0;
            }
            if(bo_tracker == NUM_KRNL){ //if write to all NUM_KRNL
                batch_tracker += 1; // go to next batch
                bo_tracker = 0; // reset to bo[0]
            }
            //TODO: track the number of batch, if full 8GB, save the current "b" and file name for next writeHBM
        }

        // std::cout<<"DONE"<<std::endl;
        file.close();
    }

    return total_written_byte;
}

/**
 * @brief Read .txt file and write to mapped bo buffers
 * This version is supposed to be capable of writing 8GB in to HBM memory
 * @param fileToSeach 
 * @param mem pointer of mapped bo buffers
 * @return size_t 
 */

size_t preprocessText(searchFile* fileToSeach, char* mem[NUM_KRNL]){
    std::ifstream file(fileToSeach->text, std::ios::binary);
    if(!file.is_open()){
        std::cout<<"Error read files"<<std::endl;
        exit(EXIT_FAILURE);
    }

    //move the read cursor to the end
    file.seekg(0,std::ios::end);
    //get the file size
    size_t fileSize = file.tellg();

    if(fileSize < KRNL_SIZE){
        std::cout<<"File size is "<<fileSize<<", less than "<<KRNL_SIZE/1024<<"KB\n";
    }else{
        std::cout<<"File size is "<<fileSize<<", start preprocess file\n";
    }

    //reset to the beginning
    file.seekg(0);
    uint32_t size_tracker = 0; //use to move the cursor in read file
    uint32_t remainder = fileSize;

    while(remainder > 0){
        //spread text to each channels = write total (xKB  - corresponding to kernel processors) to all channels
        for(int cIndex=0;cIndex<NUM_KRNL;cIndex++){
            if(remainder <= BATCH_SIZE){ //also mean end of file
                char *buffer=new char[BATCH_SIZE];
                for(int i=0; i<BATCH_SIZE;i++){buffer[i] = 0;};  //intialize with 0 for padding
                file.read(buffer,remainder);

                //copy from buffer to mapped bo
                //apply mem copy each time with 8B
                for(int m = BATCH_SIZE-8, b = 0; m>=0; m-=8, b+=8){
                    memcpy(mem[cIndex]+m, buffer+b, 8);
                }
                

                size_tracker += remainder;
                remainder -= remainder;

                #ifdef DEBUG
                // std::cout<<mem[cIndex]+fileToSeach->memTracker<<std::endl;
                std::cout<<"Remainder: "<<remainder<<std::endl; //should be 0
                std::cout<<"Mem tracker: "<<fileToSeach->memTracker<<std::endl;
                std::cout<<"Size tracker: "<<size_tracker<<std::endl; //should be fileSize
                std::cout<<"Last operation with loop "<< loop_cnt <<std::endl;
                #endif //DEBUG

                break;
            }else{ //more data in file to read
                char *buffer=new char[BATCH_SIZE];
                file.read(buffer,BATCH_SIZE); //read from file to buffer

                //copy from buffer to mapped bo
                //apply mem copy each time with 8B
                for(int m = BATCH_SIZE-8, b = 0; m>=0; m-=8, b+=8){
                    memcpy(mem[cIndex]+m, buffer+b, 8);
                }
                remainder -= BATCH_SIZE;
                size_tracker += BATCH_SIZE;
                std::cout<<buffer<<std::endl;
                //prepare the cursor position for next read file
                if(cIndex == NUM_KRNL-1){ //if writing to the last channel, move the cursor back 128 bytes
                    file.seekg(size_tracker-128);
                }else{
                    file.seekg(size_tracker); //next time, read from this position in file
                }
                
                #ifdef DEBUG
                if((cIndex == NUM_KRNL-1) || (cIndex == 0)){
                    std::cout<<mem[cIndex]+fileToSeach->memTracker<<std::endl;
                }
                std::cout<<"Remainder: "<<remainder<<std::endl;
                std::cout<<"Mem tracker: "<<fileToSeach->memTracker<<std::endl;
                std::cout<<"Size tracker: "<<size_tracker<<std::endl;
                std::cout<<"Loop cnt: "<< loop_cnt <<std::endl;
                loop_cnt++;
                #endif //DEBUG
            }
        } //end for, complete write xKB to all 32 channels

        fileToSeach->memTracker += BATCH_SIZE; // Tracking the byte address of text wrote to file
        fileToSeach->batchNum += 1;
    }

    file.close();
    return fileSize;
}

void tsp_write_address(xrt::ip krnl, std::vector<xrt::bo> bo,  uint32_t addrInBytes, uint32_t batch_cnt){
    uint32_t address_cx_base = ADDRESS_C0_L;
    for(size_t i=0, j=0; i<bo.size();i++, j=j+12){
        krnl.write_register(address_cx_base+j, bo[i].address()+(batch_cnt*(BATCH_SIZE))); //byte addressing => + xKB if file > xKB
        krnl.write_register(address_cx_base+4+j, bo[i].address() >> 32);
        // std::cout<<"addr L 0x"<<std::hex<<address_cx_base+j<<std::endl;
        // std::cout<<"addr H 0x"<<std::hex<<address_cx_base+4+j<<std::endl;
    }

	krnl.write_register(ADDRESS_LENGTH, addrInBytes);
}

void tsp_reset_key(xrt::ip krnl){
    for(uint32_t i=0;i<63;i++){
        krnl.write_register(TSP_KEY+(i*4), 0);
    }
}

std::string string_to_hex(const std::string& input){
    static const char hex_digits[] = "0123456789ABCDEF";

    std::string output;
    output.reserve(input.length() * 2);
    for (unsigned char c : input)
    {
        output.push_back(hex_digits[c >> 4]);
        output.push_back(hex_digits[c & 15]);
    }
    return output;
}

uint32_t get_num_jp_unicode(std::string str, size_t s){
    std::vector<char> c;
    uint32_t hundreds = 0;
    uint32_t tens = 0;
    uint32_t units = 0;
    // char temp[3];
    for(uint32_t b=0; b<3;b++){
        c.push_back(str[s+9+b]);
        // temp[b] = str[s+9+b];
    }
    // std::cout<<"temp: "<<temp<<std::endl;
    if(CMP_JP_DIGIT_UNIC(c)) units = (unsigned char)c[2] - (unsigned char)0x90;
    
    c.clear();
    for(uint32_t b=0; b<3;b++){
        c.push_back(str[s+6+b]);
        // temp[b] = str[s+6+b];
    }
    // std::cout<<"temp: "<<temp<<std::endl;
    if(CMP_JP_DIGIT_UNIC(c)) tens = (unsigned char)c[2] - (unsigned char)0x90;

    c.clear();
    for(uint32_t b=0; b<3;b++){
        c.push_back(str[s+3+b]);
        // temp[b] = str[s+3+b];
    }
    // std::cout<<"temp: "<<temp<<std::endl;
    if(CMP_JP_DIGIT_UNIC(c)) hundreds = (unsigned char)c[2] - (unsigned char)0x90;

    uint32_t result;
    if(units != 0){
        result = hundreds*100 + tens*10 + units;
    }else if(tens != 0){
        result = hundreds*10 + tens;
    }else{
        result = hundreds;
    }

    // std::cout<<"result jp unicode: "<<std::dec<<result<<std::endl;
    return result;
}

uint32_t get_num_jp_sjis(std::string str, size_t s){
    std::vector<char> c;
    uint32_t hundreds = 0;
    uint32_t tens = 0;
    uint32_t units = 0;
    // char temp[2];
    for(uint32_t b=0; b<2;b++){
        c.push_back(str[s+2*3+b]);
        // temp[b] = str[s+6+b];
    }
    // std::cout<<"key str: "<<string_to_hex(str)<<std::endl;
    // std::cout<<std::hex<<HEX(temp[0])<<"-"<<HEX(temp[1])<<std::endl;
    if(CMP_JP_DIGIT_SJIS(c)) units = (unsigned char)c[1] - (unsigned char)0x4f;
    
    c.clear();
    for(uint32_t b=0; b<2;b++){
        c.push_back(str[s+2*2+b]);
        // temp[b] = str[s+4+b];
    }
    // std::cout<<std::hex<<HEX(temp[0])<<"-"<<HEX(temp[1])<<std::endl;
    if(CMP_JP_DIGIT_SJIS(c)) tens = (unsigned char)c[1] - (unsigned char)0x4f;

    c.clear();
    for(uint32_t b=0; b<2;b++){
        c.push_back(str[s+2*1+b]);
        // temp[b] = str[s+2+b];
    }
    // std::cout<<std::hex<<HEX(temp[0])<<"-"<<HEX(temp[1])<<std::endl;
    if(CMP_JP_DIGIT_SJIS(c)) hundreds = (unsigned char)c[1] - (unsigned char)0x4f;

    uint32_t result;
    if(units != 0){
        result = hundreds*100 + tens*10 + units;
    }else if(tens != 0){
        result = hundreds*10 + tens;
    }else{
        result = hundreds;
    }
    // std::cout<<"result jp sjis: "<<std::dec<<result<<std::endl;
    return result;
}

int tsp_write_all_key(xrt::ip krnl, std::vector<keyWord> *keyList){
    int status = 0;
    for(size_t kIndex = 0; kIndex < keyList->size(); kIndex++){
        //Write key to kernel
        keyWord* keyToSearch = &(keyList->at(kIndex)); //list of keys in a file
        #ifdef DEBUG_SEARCH_KEY
            const char* key = (keyToSearch->key).c_str();
            printf("|   Key[%ld]: %s\n",kIndex,key);
        #endif // DEBUG_SEARCH_KEY
        if(kIndex != keyList->size()-1) status = tsp_write_key(krnl, keyToSearch, false);
        else status = tsp_write_key(krnl, keyToSearch, true);

        if(status == -1){
            std::cout<<"|   Error setting key, process the next one\n";
            return -1;
        }
    }
    return 0;
}

int tsp_write_key(xrt::ip krnl, keyWord* k, bool last){
    // tsp_reset_key(krnl);
    size_t kSize = (k->key).size();
    uint32_t cType = k->type;
    std::vector<char> c;

    if(k->useWildCard){//search with wildcards
        // std::cout<<"|   Search wildcard\n";
        uint32_t usedKeyReg = 0;
        for(size_t i=0,j=0; i<kSize;/*character track*/i+=cType,/*reg track*/j=j+4*cType){
            uint32_t register_value = 0;
            uint32_t register_value_1 = 0;
            uint32_t register_value_2 = 0;

            if(i==0) register_value |= TSP_SET_KEY_FIRST_BYTE;

            //get a character in any encode type
            c.clear();
            for(uint32_t b=0; b<cType;b++){
                c.push_back((k->key)[i+b]);
                // std::cout<<"get c: 0x"<<std::hex<<HEX(c[b])<<std::endl; 
            }
            
            //process 1 character
            switch (cType) {
            case 1:
                //set working mode
                krnl.write_register(DEV_CTRL, TSP_DEV_CTRL_MODE_1BYTE);
                if(CMP_MASK_1(c)){ // *
                    c.clear(); //clear *, dont need it anymore
                    uint32_t mask = 0;
                    if(isdigit((k->key)[i+3])){ //check if the mask >= 100
                        mask = ((k->key)[i+1] - '0')*100 + (k->key)[i+2]*10 - '0'+ (k->key)[i+3] - '0';
                    }else if(isdigit((k->key)[i+2])){ //check if the mask >= 10
                        mask = ((k->key)[i+1] - '0')*10 + (k->key)[i+2] - '0';
                    }else{ //from 1 -> 9
                        mask = (k->key)[i+1] - '0';
                    }

                    //write mask for current register
                    register_value |= TSP_SET_KEY_MASK;
                    if(i+cType == kSize){
                        register_value |= TSP_SET_KEY_LAST_BYTE;
                        if(last) register_value |= TSP_SET_KEY_LAST_KEY;
                    } 
                    
                    //write registers
                    for(uint32_t m = 0; m<mask; m++){
                        krnl.write_register(TSP_KEY, register_value);
                        #ifdef DEBUG_KEY
                        std::cout<<"|   ---debug: Mask   reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<register_value<<std::endl;
                        #endif
                    }

                    //update i and key length
                    if(mask >= 100){
                        i = i + 3;
                    }else if(mask >= 10){
                        i = i + 2;
                    }else {
                        i = i + 1;
                    }
                    usedKeyReg += mask;

                }else if(CMP_GAP_1(c)){// ?
                    c.clear(); // clear ?, dont need it anymore
                    uint32_t gap = 0; //count how many gaps

                    if(isdigit((k->key)[i+3])){ //check if the gap >= 100
                        gap = ((k->key)[i+1] - '0')*100 + (k->key)[i+2]*10 - '0'+ (k->key)[i+3] - '0';
                        c.push_back((k->key)[i+4]); //store the gap character
                    }else if(isdigit((k->key)[i+2])){ //check if the gap >= 10
                        gap = ((k->key)[i+1] - '0')*10 + (k->key)[i+2] - '0';
                        c.push_back((k->key)[i+3]); //store the gap character
                    }else{
                        gap = (k->key)[i+1] - '0';
                        c.push_back((k->key)[i+2]); //store the gap character
                    }

                    //assign register gap value
                    std::vector<uint32_t> register_value_gap;
                    for(uint32_t l=0;l<gap;l++){
                        uint32_t value = 0;
                        if(l==0){ //current register
                            value |= TSP_SET_KEY_X(c[0]) | TSP_SET_KEY_BEGIN_GAP;
                            register_value_gap.push_back(value);
                        }else if (l!= gap-1){ //middle gap
                            value |= TSP_SET_KEY_X(c[0]);
                            register_value_gap.push_back(value);
                        }else{ //last gap
                            uint32_t value = 0;
                            value |= TSP_SET_KEY_X(c[0])| TSP_SET_KET_END_GAP;
                            register_value_gap.push_back(value);
                        }
                    }
                    
                    //write registers
                    for(uint32_t g=0;g<gap;g++){
                        krnl.write_register(TSP_KEY, register_value_gap[g]); //current register
                        #ifdef DEBUG_KEY
                        std::cout<<"|   ---debug: GAP    reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<< register_value_gap[g]<<std::endl;
                        #endif
                    }

                    //update i and key length
                    if(gap >= 100){
                        i = i + 4;
                    }else if(gap >= 10){
                        i = i + 3; //next character is 3 position away
                    }else{
                        i = i + 2; //next character is 2 position away
                    }
                    usedKeyReg += gap;
                }else{  //not a wildcard character
                    register_value |= TSP_SET_KEY_X(c[0]);
                    if(i+cType == kSize) {
                        register_value |= TSP_SET_KEY_LAST_BYTE;
                        if(last) register_value |= TSP_SET_KEY_LAST_KEY;
                    }
                    #ifdef DEBUG_KEY
                    std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<register_value<<std::endl;
                    #endif
                    krnl.write_register(TSP_KEY, register_value);
                    usedKeyReg += 1;
                }
                break;
            case 2: //JP Shift-JIS
                //set working mode
                krnl.write_register(DEV_CTRL, TSP_DEV_CTRL_MODE_2BYTE);
                //check wildcard character
                if(CMP_MASK_2(c)){// ＊
                    c.clear(); //clear ＊, dont need it anymore
                    register_value |= TSP_SET_KEY_MASK;
                    uint32_t mask = get_num_jp_sjis(k->key, i);
                    for(uint32_t m = 0; m <mask*cType; m++){
                        if(i+m == kSize){ //mask character is at the end
                            #ifdef DEBUG_KEY
                            std::cout<<"|   ---debug: Mask   reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<(int)(TSP_SET_KEY_MASK | TSP_SET_KEY_LAST_BYTE)<<std::endl;
                            #endif
                            krnl.write_register(TSP_KEY, (int)(TSP_SET_KEY_MASK | TSP_SET_KEY_LAST_BYTE));
                        }else{
                            #ifdef DEBUG_KEY
                            std::cout<<"|   ---debug: Mask   reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<register_value<<std::endl;
                            #endif
                            krnl.write_register(TSP_KEY, register_value);
                        }
                    }

                    //update i and key length
                    if(mask >= 100){
                        i = i + cType*3;
                    }else if(mask >= 10){
                        i = i + cType*2;
                    }else {
                        i = i + cType*1;
                    }
                    usedKeyReg += mask*cType;

                }else if(CMP_GAP_2(c)){// ？
                    c.clear(); //clear ？, dont need it anymore
                    register_value |= TSP_SET_KEY_MASK;
                    uint32_t gap = get_num_jp_sjis(k->key, i);
                    //Get gap character
                    if(gap >= 100){
                        for(uint32_t b=0; b<cType;b++){
                            c.push_back((k->key)[i+cType*4+b]);
                        }
                    }else if(gap >= 10){
                        for(uint32_t b=0; b<cType;b++){
                            c.push_back((k->key)[i+cType*3+b]);
                        }
                    }else {
                        for(uint32_t b=0; b<cType;b++){
                            c.push_back((k->key)[i+cType*2+b]);
                        }
                    }

                    //assign register gap value
                    std::vector<uint32_t> register_value_gap;
                    for(uint32_t g=0;g<gap;g++){
                        for(uint32_t r=0; r<cType; r++){
                            uint32_t value = 0;
                            if((g==0) & (r==0)){ //current register
                                value |= TSP_SET_KEY_X(c[r]) | TSP_SET_KEY_BEGIN_GAP;
                                register_value_gap.push_back(value);
                            }else if ((g == gap-1) & (r == cType-1)){ //last gap
                                value |= TSP_SET_KEY_X(c[r])| TSP_SET_KET_END_GAP;
                                register_value_gap.push_back(value);
                            }else{ //middle gap
                                value |= TSP_SET_KEY_X(c[r]);
                                register_value_gap.push_back(value);
                            }
                        }
                    }

                    for(uint32_t g=0;g<gap*cType;g++){
                        krnl.write_register(TSP_KEY, register_value_gap[g]); //current register
                        #ifdef DEBUG_KEY
                        std::cout<<"|   ---debug: GAP    reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<< register_value_gap[g]<<std::endl;
                        #endif
                    }

                    //update i and key length
                    if(gap >= 100){
                        i = i + cType*4;
                    }else if(gap >= 10){
                        i = i + cType*3;
                    }else {
                        i = i + cType*2;
                    }
                    usedKeyReg += gap*cType;

                }else{ //not a wildcard character
                    //current register
                    register_value |= TSP_SET_KEY_X(c[0]);
                    //+1 register
                    if(i+cType == kSize) {
                        register_value_1 |= TSP_SET_KEY_LAST_BYTE;
                        if(last) register_value_1 |= TSP_SET_KEY_LAST_KEY;
                    }
                    register_value_1 |= TSP_SET_KEY_X(c[1]);
                    //start write registers
                    #ifdef DEBUG_KEY
                    std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<register_value<<std::endl;
                    std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<register_value_1<<std::endl;
                    #endif
                    krnl.write_register(TSP_KEY,   register_value);
                    krnl.write_register(TSP_KEY, register_value_1);
                    //update key length
                    usedKeyReg+=2;
                }
                break;
            case 3: // JP Unicode
                //set working mode
                krnl.write_register(DEV_CTRL, TSP_DEV_CTRL_MODE_3BYTE);
                //check wildcard character
                if(CMP_MASK_3(c)){// ＊
                    c.clear(); //clear ＊, dont need it anymore
                    register_value |= TSP_SET_KEY_MASK;
                    uint32_t mask = get_num_jp_unicode(k->key, i);
                    for(uint32_t m = 0; m <mask*cType; m++){
                        if(i+m == kSize){ //mask character is at the end
                            #ifdef DEBUG_KEY
                            std::cout<<"|   ---debug: Mask   reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<(int)(TSP_SET_KEY_MASK | TSP_SET_KEY_LAST_BYTE)<<std::endl;
                            #endif
                            krnl.write_register(TSP_KEY, (int)(TSP_SET_KEY_MASK | TSP_SET_KEY_LAST_BYTE));
                        }else{
                            #ifdef DEBUG_KEY
                            std::cout<<"|   ---debug: Mask   reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<register_value<<std::endl;
                            #endif
                            krnl.write_register(TSP_KEY, register_value);
                        }
                    }

                    //update i and key length
                    if(mask >= 100){
                        i = i + cType*3;
                    }else if(mask >= 10){
                        i = i + cType*2;
                    }else {
                        i = i + cType*1;
                    }
                    usedKeyReg += mask*cType;

                }else if(CMP_GAP_3(c)){// ？
                    c.clear(); //clear ？, dont need it anymore
                    register_value |= TSP_SET_KEY_MASK;
                    uint32_t gap = get_num_jp_unicode(k->key, i);

                    //Get gap character
                    if(gap >= 100){
                        for(uint32_t b=0; b<cType;b++){
                            c.push_back((k->key)[i+12+b]);
                        }
                    }else if(gap >= 10){
                        for(uint32_t b=0; b<cType;b++){
                            c.push_back((k->key)[i+9+b]);
                        }
                    }else {
                        for(uint32_t b=0; b<cType;b++){
                            c.push_back((k->key)[i+6+b]);
                        }
                    }

                    //assign register gap value
                    std::vector<uint32_t> register_value_gap;
                    for(uint32_t g=0;g<gap;g++){
                        for(uint32_t r=0; r<cType; r++){
                            uint32_t value = 0;
                            if((g==0) & (r==0)){ //current register
                                value |= TSP_SET_KEY_X(c[r]) | TSP_SET_KEY_BEGIN_GAP;
                                register_value_gap.push_back(value);
                            }else if ((g == gap-1) & (r == cType-1)){ //last gap
                                value |= TSP_SET_KEY_X(c[r])| TSP_SET_KET_END_GAP;
                                register_value_gap.push_back(value);
                            }else{ //middle gap
                                value |= TSP_SET_KEY_X(c[r]);
                                register_value_gap.push_back(value);
                            }
                        }
                    }

                    for(uint32_t g=0;g<gap*cType;g++){
                        krnl.write_register(TSP_KEY, register_value_gap[g]); //current register
                        #ifdef DEBUG_KEY
                        std::cout<<"|   ---debug: GAP    reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<< register_value_gap[g]<<std::endl;
                        #endif
                    }

                    //update i and key length
                    if(gap >= 100){
                        i = i + cType*4;
                    }else if(gap >= 10){
                        i = i + cType*3;
                    }else {
                        i = i + cType*2;
                    }
                    usedKeyReg += gap*cType;

                }else{ //not a wildcard character
                    //current register
                    register_value |= TSP_SET_KEY_X(c[0]);
                    //+1 register
                    register_value_1 |= TSP_SET_KEY_X(c[1]);
                    //+2 register
                    if(i+cType == kSize){
                        register_value_2 |= TSP_SET_KEY_LAST_BYTE;
                        if(last) register_value_2 |= TSP_SET_KEY_LAST_KEY;
                    }
                    register_value_2 |= TSP_SET_KEY_X(c[2]);
                    //start write registers
                    #ifdef DEBUG_KEY
                    std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<register_value<<std::endl;
                    std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<register_value_1<<std::endl;
                    std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<register_value_2<<std::endl;
                    #endif
                    krnl.write_register(TSP_KEY,   register_value);
                    krnl.write_register(TSP_KEY, register_value_1);
                    krnl.write_register(TSP_KEY, register_value_2);
                    //update key length
                    usedKeyReg+=3;
                }
                break;
            default:
                std::cout<<"Not yet support encoding "<<cType<<" bytes for keys\n";
                return -1;
                break;
            }
            
            // if(i+cType == kSize){ //last character has been processed, assign number of key register has been used
            //     krnl.write_register(KEY_LEN, TSP_SET_KEY_LEN(usedKeyReg));
            //     #ifdef DEBUG_KEY
            //     std::cout<<"|   Set key length: "<<std::dec<< usedKeyReg <<std::endl;
            //     std::cout<<"|   ---debug: Read set key len: "<<krnl.read_register(KEY_LEN)<<std::endl;
            //     #endif //DEBUG_KEY
            // }
        }
    }else{ //match search
        // std::cout<<"|   Search match\n";
        for(size_t i=0,j=0; i<kSize;/*character track*/i+=cType,/*reg track*/j=j+4*cType){
            uint32_t register_value = 0;
            uint32_t register_value_1 = 0;
            uint32_t register_value_2 = 0;

            if(i==0) register_value |= TSP_SET_KEY_FIRST_BYTE;

            //get a character in any encode type
            c.clear();
            for(uint32_t b=0; b<cType;b++){
                c.push_back((k->key)[i+b]);
            }
            switch (cType){
            case 1:
                //set working mode
                krnl.write_register(DEV_CTRL, TSP_DEV_CTRL_MODE_1BYTE);
                register_value |= TSP_SET_KEY_X(c[0]);
                if(i+cType == kSize){
                    register_value |= TSP_SET_KEY_LAST_BYTE;
                    if(last) register_value |= TSP_SET_KEY_LAST_KEY;
                } 
                #ifdef DEBUG_KEY
                std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"]: 0x"<<std::hex<<register_value<<std::endl;
                #endif
                krnl.write_register(TSP_KEY, register_value);
                break;
            case 2:
            //set working mode
                krnl.write_register(DEV_CTRL, TSP_DEV_CTRL_MODE_2BYTE);
                //current register
                register_value |= TSP_SET_KEY_X(c[0]);
                //+1 register
                if(i+cType == kSize){
                    register_value_1 |= TSP_SET_KEY_LAST_BYTE;
                    if(last) register_value_1 |= TSP_SET_KEY_LAST_KEY;
                }
                register_value_1 |= TSP_SET_KEY_X(c[1]);
                //start write
                #ifdef DEBUG_KEY
                std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"] 0: 0x"<<std::hex<<register_value<<std::endl;
                std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"] 1: 0x"<<std::hex<<register_value_1<<std::endl;
                #endif
                krnl.write_register(TSP_KEY,   register_value);
                krnl.write_register(TSP_KEY, register_value_1);
                break;
            case 3:
                //set working mode
                krnl.write_register(DEV_CTRL, TSP_DEV_CTRL_MODE_3BYTE);
                //current register
                register_value |= TSP_SET_KEY_X(c[0]);
                //+1 register
                register_value_1 |= TSP_SET_KEY_X(c[1]);
                //+2 register
                if(i+cType == kSize){
                    register_value_2 |= TSP_SET_KEY_LAST_BYTE;
                    if(last) register_value_2 |= TSP_SET_KEY_LAST_KEY;
                }
                register_value_2 |= TSP_SET_KEY_X(c[2]);
                //start write
                #ifdef DEBUG_KEY
                std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"] 0: 0x"<<std::hex<<register_value<<std::endl;
                std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"] 1: 0x"<<std::hex<<register_value_1<<std::endl;
                std::cout<<"|   ---debug: Normal reg[0x"<<std::hex<<TSP_KEY<<"] 2: 0x"<<std::hex<<register_value_2<<std::endl;
                #endif
                krnl.write_register(TSP_KEY,   register_value);
                krnl.write_register(TSP_KEY, register_value_1);
                krnl.write_register(TSP_KEY, register_value_2);
                break;
            default:
                std::cout<<"Not yet support encoding "<<cType<<" bytes for keys\n";
                return -1;
            }
        }
        
        // krnl.write_register(KEY_LEN, TSP_SET_KEY_LEN(kSize));
        #ifdef DEBUG_KEY
        // std::cout<<"|   Set key length: "<<std::dec<< kSize <<std::endl;
        // std::cout<<"|   ---debug: Read set key len: "<<krnl.read_register(KEY_LEN)<<std::endl;
        // uint32_t read_data;
        // read_data = krnl.read_register(ADDR_DEBUG0);
	    // std::cout << "|   ---debug: Key in first: " << std::hex << read_data << std::dec<< std::endl;
	    // read_data = krnl.read_register(ADDR_DEBUG1);
	    // std::cout << "|   ---debug: Key in last: " << std::hex << read_data << std::dec<< std::endl;
        #endif
    }
    return 0;
}

uint32_t waitSignal(xrt::ip krnl, uint32_t base, uint32_t offset){
    uint32_t read_data = 0;
    uint32_t counter = 0;
    while(1){
        read_data = krnl.read_register(base);
        read_data = read_data & offset;
        if (read_data == offset){
            return 0;
        }else{
            counter++;
            if(counter == 100000) return -1;
        }
    }
}

void postProcessResult(std::vector<searchFile>* listFile, std::vector<keyWord>* keyList){
    
    //sort hit address first
    for(size_t k =0; k < keyList->size(); k++){
        std::sort(keyList->at(k).hitAddr.begin(),keyList->at(k).hitAddr.end());
        for(size_t s = 0; s<keyList->at(k).hitAddr.size(); s++ ){
            // printf("hit[%ld]: %d\n", s, keyList->at(k).hitAddr[s]);
        }
    }
    
    size_t addr_bound = 0;
    for(size_t f=0; f<listFile->size(); f++){
        addr_bound += listFile->at(f).textSize;
        // std::cout<<"addr_bound: "<<addr_bound<<std::endl;
        for(size_t k=0; k<keyList->size();k++){
            while(1){
                if(!(keyList->at(k).hitAddr.empty())){
                    uint32_t hit_addr = keyList->at(k).hitAddr[0];
                    // std::cout<<k<<" hit addr: "<<hit_addr<<std::endl;
                    if(hit_addr < addr_bound){
                        keyList->at(k).hitAddr.erase(keyList->at(k).hitAddr.begin());
                        listFile->at(f).keyList[k].hitAddr.push_back(hit_addr);
                    }else{
                        break;
                    }
                }else{
                    break;
                }
            }
            // std::cout<<"key hit size: "<<listFile->at(f).keyList[k].hitAddr.size()<<std::endl;
            //update summary
            listFile->at(f).keyList.at(k).update_hitTime();
            listFile->at(f).updateFoundKey();
        }
    }
}

void exportResult(std::vector<searchFile> listFile, std::vector<keyWord> listKey, uint64_t total_size, double totalTimeSearch, uint32_t batch){
    std::ofstream  oFile(root + result_summary + "TSP_Summary_Result.txt", std::ofstream::out);

    for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
        for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
            listKey[kIndex].hitTime += listFile[fIndex].keyList[kIndex].hitTime;
        }
    }

    if(orSearch){
        oFile <<"TEXT SEARCH PROCESSOR SEARCH RESULTS\n";
        oFile<<"Search mode: OR\n";
        oFile<<"Total search files: "<<listFile.size()<<" files - "<<getByte(total_size)<<" - "<<batch<<" Batches"<<std::endl;
        int hit_files = 0;
        for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == true){
                    hit_files += 1;
                    break;
                }
            }
        }
        oFile<<"Hit files: "<<hit_files<<" files"<<std::endl;
        double size8GB = 8.0*1024.0*1024.0*1024.0;
        oFile<<"Total time search: "<<getTime(totalTimeSearch) <<" ("<< ((totalTimeSearch/(double)total_size)*size8GB)*1000.0<<"ms if 8GB database)"<<std::endl;
        oFile <<"============================================\n";
        oFile <<"Total hit of each key\n";
        for(size_t kIndex=0; kIndex<listKey.size(); kIndex++){
            oFile <<"|   Keyword "<<kIndex+1<<": #Hit = "<<listKey[kIndex].hitTime<<std::endl;
        }
        for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
            bool isPrinted = false;
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == true){
                    isPrinted = true;
                    break;
                }
            }
            if(isPrinted){
                oFile <<"============================================\n";
                oFile <<"File ["<<listFile[fIndex].name<<"]:\n";
                oFile <<"|   File path: "<<listFile[fIndex].text<<std::endl;
                oFile <<"|   File size: "<<getByte(listFile[fIndex].textSize)<<std::endl;
                oFile <<"|-------------------------------------------\n";
                for(size_t kIndex = 0; kIndex<listFile[fIndex].keyListSize; kIndex++){
                    keyWord temp = listFile[fIndex].keyList[kIndex];
                    // oFile <<"|   Key #"<<kIndex<<" ["<<temp.key<<"]: #Hit = "<<temp.hitTime<<std::endl;
                    oFile <<"|   Keyword "<<kIndex+1<<": #Hit = "<<temp.hitTime<<std::endl;
                }
            }
        }
    }
    if(andSearch){
        oFile <<"TEXT SEARCH PROCESSOR SEARCH RESULTS\n";
        oFile<<"Search mode: AND\n";
        oFile<<"Total search files: "<<listFile.size()<<" files - "<<getByte(total_size)<<" - "<<batch<<" Batches"<<std::endl;
        int hit_files = 0;
        for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
            bool isHit = true;
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == false){
                    isHit = false;
                    break;
                }
            }
            if(isHit) hit_files += 1;
        }
        oFile<<"Hit files: "<<hit_files<<" files"<<std::endl;
        double size8GB = 8.0*1024.0*1024.0*1024.0;
        oFile<<"Total time search: "<<getTime(totalTimeSearch) <<" ("<< ((totalTimeSearch/(double)total_size)*size8GB)*1000.0<<"ms if 8GB database)"<<std::endl;

        oFile <<"============================================\n";
        oFile <<"Total hit of each key\n";
        for(size_t kIndex=0; kIndex<listKey.size(); kIndex++){
            oFile <<"|   Keyword "<<kIndex+1<<": #Hit = "<<listKey[kIndex].hitTime<<std::endl;
        }

        for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
            bool isPrinted = true;
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == false){
                    isPrinted = false;
                    break;
                }
            }
            if(isPrinted){
                oFile <<"============================================\n";
                oFile <<"File ["<<listFile[fIndex].name<<"]:\n";
                oFile <<"|   File path: "<<listFile[fIndex].text<<std::endl;
                oFile <<"|   File size: "<<getByte(listFile[fIndex].textSize)<<std::endl;
                oFile <<"|-------------------------------------------\n";
                for(size_t kIndex = 0; kIndex<listFile[fIndex].keyListSize; kIndex++){
                    keyWord temp = listFile[fIndex].keyList[kIndex];
                    // oFile <<"|   Key #"<<kIndex<<" ["<<temp.key<<"]: #Hit = "<<temp.hitTime<<std::endl;
                    oFile <<"|   Keyword "<<kIndex+1<<": #Hit = "<<temp.hitTime<<std::endl;
                }
            }
        }
    }
    oFile.close();
    std::cout<<"Exported result file\n";
}

void printResult(std::vector<searchFile> listFile, uint64_t total_size, double totalTimeSearch, uint32_t batch){
    if(orSearch){
        std::cout <<std::endl<<"TEXT SEARCH PROCESSOR SEARCH RESULTS\n";
        std::cout<<"Search mode: OR Search\n";
        std::cout<<"Total search files: "<<listFile.size()<<" files - "<<getByte(total_size)<<" - "<<batch<<" Batches"<<std::endl;
        int hit_files = 0;
        for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == true){
                    hit_files += 1;
                    break;
                }
            }
        }
        std::cout<<"Hit files: "<<hit_files<<" files"<<std::endl;
        double size8GB = 8.0*1024.0*1024.0*1024.0;
        std::cout<<"Total time search: "<<getTime(totalTimeSearch) <<" ("<< ((totalTimeSearch/(double)total_size)*size8GB)*1000.0<<"ms if 8GB database)"<<std::endl;
        
        for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
            bool isPrinted = false;
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == true){
                    isPrinted = true;
                    break;
                }
            }
            if(isPrinted){
                std::cout <<"============================================\n";
                std::cout <<"File ["<<listFile[fIndex].name<<"]:\n";
                std::cout <<"|   File path: "<<listFile[fIndex].text<<std::endl;
                std::cout <<"|   File size: "<<getByte(listFile[fIndex].textSize)<<std::endl;
                std::cout <<"|-------------------------------------------\n";
                for(size_t kIndex = 0; kIndex<listFile[fIndex].keyListSize; kIndex++){
                    keyWord temp = listFile[fIndex].keyList[kIndex];
                    std::cout <<"|   Key "<<kIndex+1<<" ["<<temp.key<<"]: #Hit = "<<temp.hitTime<<std::endl;
                }
            }            
        }
    }
    if(andSearch){
        std::cout <<std::endl<<"TEXT SEARCH PROCESSOR SEARCH RESULTS\n";
        std::cout<<"Search mode: AND Search\n";
        std::cout<<"Total search files: "<<listFile.size()<<" files - "<<getByte(total_size)<<" - "<<batch<<" Batches"<<std::endl;
        int hit_files = 0;
        for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
            bool isHit = true;
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == false){
                    isHit = false;
                    break;
                }
            }
            if(isHit) hit_files += 1;
        }
        std::cout<<"Hit files: "<<hit_files<<" files"<<std::endl;
        double size8GB = 8.0*1024.0*1024.0*1024.0;
        std::cout<<"Total time search: "<<getTime(totalTimeSearch) <<" ("<< ((totalTimeSearch/(double)total_size)*size8GB)*1000.0<<"ms if 8GB database)"<<std::endl;
        for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
            bool isPrinted = true;
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == false){
                    isPrinted = false;
                    break;
                }
            }
            if(isPrinted){
                std::cout <<"============================================\n";
                std::cout <<"File ["<<listFile[fIndex].name<<"]:\n";
                std::cout <<"|   File path: "<<listFile[fIndex].text<<std::endl;
                std::cout <<"|   File size: "<<getByte(listFile[fIndex].textSize)<<std::endl;
                std::cout <<"|-------------------------------------------\n";
                for(size_t kIndex = 0; kIndex<listFile[fIndex].keyListSize; kIndex++){
                    keyWord temp = listFile[fIndex].keyList[kIndex];
                    std::cout <<"|   Key "<<kIndex+1<<" ["<<temp.key<<"]: #Hit = "<<temp.hitTime<<std::endl;
                }
            }
        }
    }
}

void exportHit(std::vector<searchFile> listFile, uint64_t total_size, double totalTimeSearch, uint32_t batch){

    std::ofstream  oFile(root + result_summary + "TSP_hit_Result.txt", std::ofstream::out);
    
    if(orSearch){
        oFile <<"TEXT SEARCH PROCESSOR SEARCH RESULTS\n";
        oFile <<"Output mode: Hit\n";
        oFile<<"Total search files: "<<listFile.size()<<" files - "<<getByte(total_size)<<" - "<<batch<<" Batches"<<std::endl;
            int hit_files = 0;
            for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
                for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                    if(listFile[fIndex].foundKey[kIndex] == true){
                        hit_files += 1;
                        break;
                    }
                }
            }
        oFile<<"Hit files: "<<hit_files<<" files"<<std::endl;
        double size8GB = 8.0*1024.0*1024.0*1024.0;
        oFile<<"Total time search: "<<getTime(totalTimeSearch) <<" ("<< ((totalTimeSearch/(double)total_size)*size8GB)*1000.0<<"ms if 8GB database)"<<std::endl;

        for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
            bool isPrinted = false;
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == true){
                    isPrinted = true;
                    break;
                }
            }
            if(isPrinted){
                oFile <<"============================================\n";
                oFile <<"File ["<<listFile[fIndex].name<<"]:\n";
                oFile <<"|   File path: "<<listFile[fIndex].text<<std::endl;
                oFile <<"|   File size: "<<getByte(listFile[fIndex].textSize)<<std::endl;
                oFile <<"|-------------------------------------------\n";
                for(size_t kIndex = 0; kIndex<listFile[fIndex].keyListSize; kIndex++){
                    oFile <<"|   Keyword "<<kIndex+1<<": Hit = True"<<std::endl;
                }
            }
        }
    }
    
    if(andSearch){
        oFile <<"TEXT SEARCH PROCESSOR SEARCH RESULTS\n";
        oFile<<"Search mode: AND\n";
        oFile<<"Total search files: "<<listFile.size()<<" files - "<<getByte(total_size)<<" - "<<batch<<" Batches"<<std::endl;
        int hit_files = 0;
        for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
            bool isHit = true;
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == false){
                    isHit = false;
                    break;
                }
            }
            if(isHit) hit_files += 1;
        }
        oFile<<"Hit files: "<<hit_files<<" files"<<std::endl;
        double size8GB = 8.0*1024.0*1024.0*1024.0;
        oFile<<"Total time search: "<<getTime(totalTimeSearch) <<" ("<< ((totalTimeSearch/(double)total_size)*size8GB)*1000.0<<"ms if 8GB database)"<<std::endl;
        for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
            bool isPrinted = true;
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == false){
                    isPrinted = false;
                    break;
                }
            }
            if(isPrinted){
                oFile <<"============================================\n";
                oFile <<"File ["<<listFile[fIndex].name<<"]:\n";
                oFile <<"|   File path: "<<listFile[fIndex].text<<std::endl;
                oFile <<"|   File size: "<<getByte(listFile[fIndex].textSize)<<std::endl;
                oFile <<"|-------------------------------------------\n";
                for(size_t kIndex = 0; kIndex<listFile[fIndex].keyListSize; kIndex++){
                    keyWord temp = listFile[fIndex].keyList[kIndex];
                    oFile <<"|   Keyword "<<kIndex+1<<": Hit = True"<<std::endl;
                }
            }
        }
    }
}

void exportHitAddress(std::vector<searchFile> listFile){
    for(size_t fIndex=0; fIndex<listFile.size(); fIndex++){
        if(orSearch){
            bool isPrinted = false;
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == true){
                    isPrinted = true;
                    break;
                }
            }

            if(isPrinted){
                std::stringstream ss;
                ss <<root+ result_hit + "Result_"<<listFile[fIndex].name;
                std::string fileName = ss.str();
                std::ofstream  oFile(fileName);

                for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                    keyWord temp = listFile[fIndex].keyList[kIndex];
                    oFile <<"Keyword["<<temp.key<<"]: \n";
                    sort(temp.hitAddr.begin(), temp.hitAddr.end());
                    for(size_t i = 0; i < temp.hitAddr.size(); i++){
                        oFile <<temp.hitAddr[i]<<std::endl;
                    }
                }

                oFile.close();
            }
        }

        if(andSearch){
            bool isPrinted = true;
            for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                if(listFile[fIndex].foundKey[kIndex] == false){
                    isPrinted = false;
                    break;
                }
            }
            if(isPrinted){
                std::stringstream ss;
                ss <<root + result_hit + "Result_"<<listFile[fIndex].name;
                std::string fileName = ss.str();
                std::ofstream  oFile(fileName);

                for(size_t kIndex=0; kIndex<(listFile[fIndex]).keyListSize; kIndex++){
                    keyWord temp = listFile[fIndex].keyList[kIndex];
                    oFile <<"Keyword["<<temp.key<<"]: \n";
                    sort(temp.hitAddr.begin(), temp.hitAddr.end());
                    for(size_t i = 0; i < temp.hitAddr.size(); i++){
                        oFile <<temp.hitAddr[i]<<std::endl;
                    }
                }

                oFile.close();
            }
        }
       
    }
    std::cout<<"Exported hit files\n";
}

void exportDummy(){
    std::ofstream  oFile(root + result_summary + "finish.txt", std::ofstream::out);
    oFile<<".";
    oFile.close();

}

std::string getTime(double time){
    std::string sTime = "";
    std::stringstream ss;
    double temp = time * 1000 * 1000;
    if(temp > 1000*1000){
        temp /= 1000*1000;
        ss <<std::fixed<<std::setprecision(3)<<temp<<" s";
    }else if(temp > 1000){
        temp /= 1000;
        ss <<std::fixed<<std::setprecision(3)<<temp<<" ms";
    }else{
        ss <<std::fixed<<std::setprecision(3)<<temp<<" us";
    }
    sTime = ss.str();
    return sTime;
}

std::string getByte(uint32_t byte){
    std::string sByte = "";
    std::stringstream ss;
    double temp = byte;
    if(temp > 1024*1024*1024){
        temp /= 1024*1024*1024;
        ss <<std::fixed<<std::setprecision(3)<<temp<<" GBytes";
    }else if(temp > 1024*1024){
        temp /= 1024*1024;
        ss <<std::fixed<<std::setprecision(3)<<temp<<" MBytes";
    }else if(temp > 1024){
        temp /= 1024;
        ss <<std::fixed<<std::setprecision(3)<<temp<<" KBytes";
    }else{
        ss <<temp<<" Bs";
    }

    sByte = ss.str();
    return sByte;
}
