//
//  CGRCircularVector.h
//  CGRCore
//
//  Created by Alfredo Cruz on 3/9/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//
// This file is part of CGRCore.

// CGRCore is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// CGRCore is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with CGRCore.  If not, see <http://www.gnu.org/licenses/>.


#ifndef CGRCore_CGRCircularVector_h
#define CGRCore_CGRCircularVector_h

class CGRCircularVectorException {};

class CGRCircularVectorOutOfMemoryException:CGRCircularVectorException{};

class CGRCircularVectorIndexException:CGRCircularVectorException{};

class CGRCircularVectorNoComparatorException:CGRCircularVectorException{};

class CGRCircularvectorNoStartElementFound:CGRCircularVectorException{};

class CGRCircularVectorNoSortedException:CGRCircularVectorException{};

class CGRCircularVectorNoElementException:CGRCircularVectorException{};

template <class VECTOR_DATA>
class CGRCircularVector {
    
private:
    
    enum CGRCircularVector_ReturnStatus
    {
        OK,                 //The insert was without errors
        CHUNK_SPILLED,      //The chunk spilled, need to split it
    };
    
    struct _vectorChunkDef
    {
    private:
        void _heapSort()
        {
            uint32_t _count = this ->chunkSize();
            _buildMaxHeap(_count);
            
            for(uint32_t i=this ->chunkSize() - 1; i != 0; i--){
                VECTOR_DATA tmp = _chunkData[i];
                _chunkData[i] = _chunkData[0];
                _chunkData[0] = tmp;
                _maxHeapify(0, --_count);
            }
            
        }
        
        void _buildMaxHeap(uint32_t count)
        {
            for(uint32_t i = count >> 1; i != (uint32_t)-1; i--){
                this ->_maxHeapify(i, count);
            }
        }
        
        void _maxHeapify(uint32_t root, uint32_t _count)
        {
            uint32_t left, right, largest;
            left = (root<<1) + 1;
            right = (root + 1) << 1;
            (left < _count && _comparator(_chunkData[root],_chunkData[left]) < 0)?largest = left:largest = root;
            (right < _count && _comparator(_chunkData[largest],_chunkData[right]) < 0)?largest = right:largest = largest;
            if(largest != root){
                VECTOR_DATA tmp = _chunkData[largest];
                _chunkData[largest] = _chunkData[root];
                _chunkData[root] = tmp;
                this ->_maxHeapify(largest, _count);
            }
            
        }
    public:
        VECTOR_DATA *_chunkData;
        uint32_t _chunkSize;
        uint32_t _nextFreeIndex;
        //uint32_t _nextFreeInsertIndex;
        uint32_t _insertChunkSize;
        int (*_comparator)(VECTOR_DATA,VECTOR_DATA);
        
        _vectorChunkDef()
        {
            _chunkData = NULL;
            _chunkSize = 0;
            _nextFreeIndex = 0;
            //_nextFreeInsertIndex = 0;
            _insertChunkSize = 0;
        }
        
        ~_vectorChunkDef()
        {
            if(_chunkData != NULL){
                free(_chunkData);
                _chunkData = NULL;
                _chunkSize = 0;
                _nextFreeIndex = 0;
                //_nextFreeInsertIndex = 0;
                _insertChunkSize = 0;
            }
        }
        
        
        void init(uint32_t chunkSize)
        {
            _chunkSize = chunkSize;
            _insertChunkSize = _chunkSize >> 2;
            if(_insertChunkSize == 0)
                _insertChunkSize = 5;
            _chunkData = (VECTOR_DATA *)malloc(sizeof(VECTOR_DATA)*(_chunkSize + _insertChunkSize));
            if(_chunkData == NULL) {
                //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
                //@throw e;
                CGRCircularVectorOutOfMemoryException exception;
                throw exception;
            }
            _nextFreeIndex = 0;
            //_nextFreeInsertIndex = _chunkSize;
        }
        
        void release()
        {
            if(_chunkData != NULL){
                free(_chunkData);
                _chunkData = NULL;
                _chunkSize = 0;
                _nextFreeIndex = 0;
                //_nextFreeInsertIndex = 0;
                _insertChunkSize = 0;
            }
        }
        
        
        uint32_t addIntoChunk(VECTOR_DATA newData){
            if(_nextFreeIndex >= _chunkSize){
                return -1;
            }
            _chunkData[_nextFreeIndex++] = newData;
            return _nextFreeIndex - 1;
        }
        
        VECTOR_DATA elementAtIndex(uint32_t index){
            if(index != -1 && index < _chunkSize + _insertChunkSize){
                return _chunkData[index];
            }
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"Index is not valid for the chunk size" userInfo:nil];
            //@throw e;
            CGRCircularVectorIndexException exception;
            throw exception;
        }
        
        
        uint32_t chunkSize()
        {
            /*if(_nextFreeIndex > _chunkSize){
                return _nextFreeIndex;
            }
            return _chunkSize;*/
            //return _nextFreeInsertIndex;
            return _nextFreeIndex;
        }
        
        void insertIntoChunk(VECTOR_DATA newData, uint32_t index){
            //Check if we have insert `capacity`
            if(_nextFreeIndex - _chunkSize == _insertChunkSize - 1){
                //We don't have enough space, so we have to alloc a new chunk
                //with _chunkSize = chunkSize();
                VECTOR_DATA *tmpVector = _chunkData;
                _chunkData = (VECTOR_DATA *)malloc(sizeof(VECTOR_DATA)*(_chunkSize + 2*_insertChunkSize));
                if(_chunkData == NULL) {
                    //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
                    _chunkData = tmpVector;
                    //@throw e;
                    CGRCircularVectorOutOfMemoryException exception;
                    throw exception;
                }
                memcpy(_chunkData, tmpVector, sizeof(VECTOR_DATA)*(_chunkSize + _insertChunkSize));
                _chunkSize += _insertChunkSize;
            }
            
            if(index > _nextFreeIndex){
                //We want to insert at an index not used should not happen but just to be safe 
                //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"Index out of range of Vector" userInfo:nil];
                //@throw e;
                CGRCircularVectorIndexException exception;
                throw exception;
            }
            if(index < _nextFreeIndex)
            {
                //Shift all the elements from index up to _nextFreeIndex one place to the right
                uint32_t pos = _nextFreeIndex - 1;
                while(pos != index){
                    _chunkData[pos+1] = _chunkData[pos];
                    pos--;
                }
                _chunkData[index+1] = _chunkData[index];
                _chunkData[index] = newData;
                _nextFreeIndex++;
            }else{
                _chunkData[_nextFreeIndex++] = newData;
            }
        }
        
        void _insertElementsAtIndex(VECTOR_DATA *elements, uint32_t count, uint32_t startIndex){
            //Just to be sure
            if(startIndex > _nextFreeIndex){
                //We want to remove at an index not used
                //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"Index out of range of Vector" userInfo:nil];
                //@throw e;
                CGRCircularVectorIndexException exception;
                throw exception;
            }
            //Alloc space for count elements
            VECTOR_DATA *tmpVector = _chunkData;
            _chunkData = (VECTOR_DATA *)malloc(sizeof(VECTOR_DATA)*(_chunkSize + _insertChunkSize + count));
            if(_chunkData == NULL) {
                //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
                _chunkData = tmpVector;
                //@throw e;
                CGRCircularVectorOutOfMemoryException exception;
                throw exception;
                
            }
            _chunkSize += count;
            
            memcpy(_chunkData, tmpVector, sizeof(VECTOR_DATA)*startIndex);
            memcpy(((VECTOR_DATA *)_chunkData) + startIndex + count, ((VECTOR_DATA *)tmpVector)+startIndex, sizeof(VECTOR_DATA)*(_nextFreeIndex - startIndex));
            memcpy(((VECTOR_DATA *)_chunkData) + startIndex, elements, sizeof(VECTOR_DATA)*count);
            
            
            
        }
        
        VECTOR_DATA removeAtIndex(uint32_t index){
            if(index >= _nextFreeIndex){
                //We want to remove at an index not used
                //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"Index out of range of Vector" userInfo:nil];
                //@throw e;
                CGRCircularVectorIndexException exception;
                throw exception;
            }
            //Shift all the elements from index up to _nextFreeIndex one place to the left
            uint32_t pos = index + 1;
            if(pos == _nextFreeIndex){
                _nextFreeIndex--;
                return _chunkData[index];
            }
            VECTOR_DATA tmp = _chunkData[index];
            while(pos != _nextFreeIndex){
                _chunkData[pos-1] = _chunkData[pos];
                pos++;
            }
            _nextFreeIndex--;
            return tmp;
        }
        
        VECTOR_DATA replaceElementAtIndex(uint32_t index, VECTOR_DATA newData)
        {
            if(index >= _nextFreeIndex){
                //We want to remove at an index not used
                //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"Index out of range of Vector" userInfo:nil];
                //@throw e;
                CGRCircularVectorIndexException exception;
                throw exception;
            }
            VECTOR_DATA tmp = _chunkData[index];
            _chunkData[index] = newData;
            return tmp;
        }
        
        
        void copyDataToBuffer(VECTOR_DATA *buffer, uint32_t startBufferIndex, uint32_t startIndex, uint32_t endIndex){
            if(endIndex < startIndex)
                return;
            if(endIndex > _nextFreeIndex){
                return;
            }
            for(int i=startIndex; i != endIndex; i++){
                buffer[startBufferIndex++] = _chunkData[i];
            }
        }
        
        void sortUsingComparator(int (*_comp)(VECTOR_DATA,VECTOR_DATA))
        {
            if(_comp == NULL){
                //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"No comparator for sorting" userInfo:nil];
                //@throw e;
                CGRCircularVectorIndexException exception;
                throw exception;
            }
            _comparator = _comp;
            this ->_heapSort();
        }
        
        uint32_t insertionIndexForElement(int (*_comp)(VECTOR_DATA,VECTOR_DATA),
                                          VECTOR_DATA element)
        {
            uint32_t base, top, curnt;
            base = 0; top = this ->chunkSize();
            curnt = top >> 1;
            
            while(base != top - 1)
            {
                if(_comp(_chunkData[curnt],element) < 0 ||
                   _comp(_chunkData[curnt],element) == 0){
                    base = curnt;
                }else{
                    top = curnt;
                }
                curnt = (top + base) >> 1;
            }
            if(base == 0){
                if(_comp(_chunkData[base],element) < 0)
                    return top;
                return base;
            }
            else
                return top;
            
        }
        
    };
    
    struct _sortChunkHeader
    {
        VECTOR_DATA minVal;
        VECTOR_DATA maxVal;
        struct _vectorChunkDef *ptr;
    };
    
    
    struct _dirElement
    {
        uint32_t minGlobalIndex;
        uint32_t maxGlobalIndex;
        bool validEntry;
    };
    
    //Directory
    struct _dirElement *_vectorDirectory;
    uint32_t _lastDirectoryEntry;
    
    //List of vector chunks
    struct _vectorChunkDef **_chunksList;
    
    uint32_t _vectorSize; //The size of the vector
    uint32_t _chunkListSize; //The size of the chunk list;
    uint32_t _vectorStdChunkSize; //The `default` size of the chunk size
    uint32_t _vectorCapacity; //The capacity of the vector
    uint32_t _vectorCurntAddChunk; //The index of the latest chunk used for add
    
    
    uint32_t _vectorIterIndex;      //The curnt iteration index
    uint32_t _vectorCurntIterChunk; //The chunk that held the last item in the iteration
    uint32_t _vectorCurntIterIndex; //The chunk's index that held the last item in the iteration
    
    int (*_comparator)(VECTOR_DATA,VECTOR_DATA);
    
    //////////////////////// DEBUG  /////////////////////////
    //uint32_t inserts_adds;
    //uint32_t removes;
    
    
    
    void _init(uint32_t size, uint32_t chunkSize)
    {
        if(size == 0){
            chunkSize = 10;
        }else if(size < chunkSize)
            _vectorStdChunkSize = size;
        else
            _vectorStdChunkSize = chunkSize;
        
        _chunkListSize = size/chunkSize;
        if(size % chunkSize != 0){
            _chunkListSize++;
        }
        
        _chunksList = (struct _vectorChunkDef **)malloc(sizeof(struct _vectorChunkDef *)*_chunkListSize);
        if(_chunksList == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
            //@throw e;
            CGRCircularVectorOutOfMemoryException exception;
            throw exception;
        }
        
        _vectorDirectory = (struct _dirElement *)malloc(sizeof(struct _dirElement)*_chunkListSize);
        if(_vectorDirectory == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector directory" userInfo:nil];
            //@throw e;
            CGRCircularVectorOutOfMemoryException exception;
            throw exception;
        }
        //Directory Initialization
        for(uint32_t i=0; i != _chunkListSize; i++){
            _vectorDirectory[i].minGlobalIndex = 0;
            _vectorDirectory[i].maxGlobalIndex= 0;
            _vectorDirectory[i].validEntry = false;
        }
        
        _vectorDirectory[0].validEntry = true;
        _lastDirectoryEntry = 1;
        
        
        _vectorCapacity = 0;
        for(uint32_t i = 0; i != _chunkListSize; i++){
            _chunksList[i] = (struct _vectorChunkDef *)malloc(sizeof(struct _vectorChunkDef));
            if(_chunksList[i] == NULL){
                //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
                //@throw e;
                CGRCircularVectorOutOfMemoryException exception;
                throw exception;
            }
            _chunksList[i] ->init(_vectorStdChunkSize);
            _vectorCapacity += _vectorStdChunkSize;
            if(_vectorCapacity < size)
                continue;
            break;
        }
        _vectorSize = 0;
        _vectorIterIndex = 0;
        _vectorCurntIterChunk = 0;
        _vectorCurntAddChunk = 0;
        _comparator = NULL;
    }
    
    void _increaseVector(){
        _chunkListSize += 2;
        struct _vectorChunkDef **tmpChunkList = _chunksList;
        _chunksList = (struct _vectorChunkDef **)malloc(sizeof(struct _vectorChunkDef *)*_chunkListSize);
        if(_chunksList == NULL){
            _chunkListSize -= 2;
            _chunksList = tmpChunkList;
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
            //@throw e;
            CGRCircularVectorOutOfMemoryException exception;
            throw exception;
        }
        
        
        for(uint32_t i = 0; i != _chunkListSize-2; i++){
            _chunksList[i] = tmpChunkList[i];
        }
        
        
        for(uint32_t i = _chunkListSize - 2; i != _chunkListSize; i++){
            _chunksList[i] = (struct _vectorChunkDef *)malloc(sizeof(struct _vectorChunkDef));
            if(_chunksList[i] == NULL){
                _chunkListSize = i;
                //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
                //@throw e;
                CGRCircularVectorOutOfMemoryException exception;
                throw exception;
            }

            _chunksList[i] ->init(_vectorStdChunkSize);
            _vectorCapacity += _vectorStdChunkSize;
        }
        free(tmpChunkList);
        
        //Now increase the directory
        struct _dirElement *tmpDir = _vectorDirectory;
        _vectorDirectory = (struct _dirElement *)malloc(sizeof(struct _dirElement)*_chunkListSize);
        if(_vectorDirectory == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector directory" userInfo:nil];
            //@throw e;
            CGRCircularVectorOutOfMemoryException exception;
            throw exception;
        }
        memcpy(_vectorDirectory, tmpDir, sizeof(struct _dirElement)*(_chunkListSize-2));
        for(uint32_t i=_chunkListSize-2; i != _chunkListSize; i++){
            _vectorDirectory[i].minGlobalIndex = 0;
            _vectorDirectory[i].maxGlobalIndex = 0;
            _vectorDirectory[i].validEntry = false;
        }
        
        free(tmpDir);
        
    }
    
    void _chunkSpilled(uint32_t spilledChunk){
        
        _chunkListSize++;
        struct _vectorChunkDef **tmpChunkList = _chunksList;
        _chunksList = (struct _vectorChunkDef **)malloc(sizeof(struct _vectorChunkDef *)*_chunkListSize);
        
        for(uint32_t i = 0; i != spilledChunk; i++){
            _chunksList[i] = tmpChunkList[i];
        }
        for(uint32_t i = spilledChunk + 1; i != _chunkListSize-1; i++){
            _chunksList[i+1] = tmpChunkList[i];
        }
        
        //Update the directory
        struct _dirElement *tmpDir = _vectorDirectory;
        
        _vectorDirectory = (struct _dirElement *)malloc(sizeof(struct _dirElement)*_chunkListSize);
        
        for(uint32_t i = 0; i != spilledChunk; i++){
            _vectorDirectory[i] = tmpDir[i];
        }
        for(uint32_t i = spilledChunk + 1; i != _chunkListSize-1; i++){
            _vectorDirectory[i+1] = tmpDir[i];
        }
        
        uint32_t spilledChunkSize = tmpChunkList[spilledChunk]->chunkSize();
        
        _chunksList[spilledChunk] = (struct _vectorChunkDef *)malloc(sizeof(struct _vectorChunkDef));
        if(_chunksList[spilledChunk] == NULL)
        {
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
            //@throw e;
            CGRCircularVectorOutOfMemoryException exception;
            throw exception;
        }
        _chunksList[spilledChunk] ->init(spilledChunkSize >> 1);
        
        
        _chunksList[spilledChunk + 1] = (struct _vectorChunkDef *)malloc(sizeof(struct _vectorChunkDef));
        if(_chunksList[spilledChunk + 1] == NULL)
        {
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
            //@throw e;
            CGRCircularVectorOutOfMemoryException exception;
            throw exception;
        }
        
        if(spilledChunkSize % 2){
            
            _chunksList[spilledChunk + 1] ->init( (spilledChunkSize >> 1) + 1);
            
        }else{
            _chunksList[spilledChunk + 1] ->init(spilledChunkSize >> 1);
        }
        uint32_t toCopyIndex = spilledChunkSize >> 1;
        tmpChunkList[spilledChunk] ->copyDataToBuffer(_chunksList[spilledChunk] ->_chunkData, 0, 0, toCopyIndex);
        
        tmpChunkList[spilledChunk] -> copyDataToBuffer(_chunksList[spilledChunk+1]->_chunkData, 0, toCopyIndex, spilledChunkSize);
        
        _chunksList[spilledChunk] ->_nextFreeIndex = toCopyIndex;
        _chunksList[spilledChunk+1]->_nextFreeIndex =spilledChunkSize - toCopyIndex;
        
        _vectorDirectory[spilledChunk].validEntry = true;
        if(spilledChunk != 0)
            _vectorDirectory[spilledChunk].minGlobalIndex = _vectorDirectory[spilledChunk-1].maxGlobalIndex;
        else
            _vectorDirectory[spilledChunk].minGlobalIndex = 0;
        _vectorDirectory[spilledChunk].maxGlobalIndex = _vectorDirectory[spilledChunk].minGlobalIndex + _chunksList[spilledChunk] ->chunkSize();
        
        _vectorDirectory[spilledChunk+1].validEntry = true;
        _vectorDirectory[spilledChunk+1].minGlobalIndex = _vectorDirectory[spilledChunk].maxGlobalIndex;
        _vectorDirectory[spilledChunk+1].maxGlobalIndex = _vectorDirectory[spilledChunk+1].minGlobalIndex + _chunksList[spilledChunk+1] ->chunkSize();
        _lastDirectoryEntry++;
        
        //tmpChunkList[spilledChunkSize]->release();
        tmpChunkList[spilledChunk]->release();
        free(tmpChunkList);
    }
    
    //Iterator
    struct iterIndex
    {
        uint32_t chunkIndex;
        uint32_t localIndex;
    };
    inline struct iterIndex _localIndexForGlobalIndex(uint32_t index)
    {
        /*
        uint32_t nextIndex = index;
        uint32_t chunkIndex = 0;
        //Find the chunk holding the next free space
        for ( ; chunkIndex != _chunkListSize; chunkIndex++) {
            
            if(nextIndex > _chunksList[chunkIndex]->chunkSize()-1){
                nextIndex -= _chunksList[chunkIndex]->chunkSize();
                continue;
            }
            break;
        }
        struct iterIndex ret1;
        ret1.chunkIndex = chunkIndex;
        ret1.localIndex = nextIndex;
        //return ret;
        */
        uint32_t base, curnt, top;
        base = 0;
        //for(top = 0; top != _chunkListSize && _vectorDirectory[top].validEntry; top++);
        top = _lastDirectoryEntry;
        curnt = top >> 1;
        
        while(base != curnt)
        {
            if(_vectorDirectory[curnt].maxGlobalIndex <= index){
                base = curnt;
            }else if(_vectorDirectory[curnt].minGlobalIndex > index){
                top = curnt;
            }else{
                break;
            }
            curnt = (top + base) >> 1;
        }
        struct iterIndex ret;
        ret.chunkIndex = curnt;
        ret.localIndex = index - _vectorDirectory[curnt].minGlobalIndex;
        
        return ret;
    }
    
    //Corrects the iteration index according to the insert/remove operation (op)
    void _modIterIndexForOperation(short op, uint32_t index)
    {
        if(index == _vectorIterIndex)
            return;
        
        switch (op) {
            case 1: //Insert
                if(index < _vectorIterIndex){
                    if(_vectorCurntIterIndex == 0){
                        if(_vectorCurntIterChunk == 0){
                            //Return to the last chunk
                            _vectorCurntIterChunk = _chunkListSize - 1;
                            _vectorCurntIterIndex = _chunksList[_vectorCurntIterChunk]->chunkSize() - 1;
                        }else{
                            _vectorCurntIterChunk--;
                            _vectorCurntIterIndex = _chunksList[_vectorCurntIterChunk]->chunkSize() - 1;
                        }
                    }else{
                        _vectorCurntIterIndex--;
                    }
                }
                break;
            case 2://Remove
                if(index < _vectorIterIndex){
                    if(_vectorCurntIterIndex == _chunksList[_vectorCurntIterChunk]->chunkSize() - 1){
                        _vectorCurntIterChunk++;
                        if(_vectorCurntIterChunk == _chunkListSize){
                            _vectorCurntIterChunk = 0;
                        }
                        _vectorCurntIterIndex = 0;
                    }else{
                        _vectorCurntIterIndex++;
                    }
                }
            default:
                break;
        }
    }
    
    
    //Sorting
    void _heapSort(int (*_comp)(VECTOR_DATA,VECTOR_DATA), struct _sortChunkHeader *headers, uint32_t _count)
    {
        _buildMaxHeap(_comp, headers, _count);
        
        for(uint32_t i=_count - 1; i != 0; i--){
            struct _sortChunkHeader tmp = headers[i];
            headers[i] = headers[0];
            headers[0] = tmp;
            _maxHeapify(_comp, headers, 0, --_count);
        }
        
    }
    
    void _buildMaxHeap(int (*_comp)(VECTOR_DATA,VECTOR_DATA), struct _sortChunkHeader *headers, uint32_t count)
    {
        for(uint32_t i = count >> 1; i != (uint32_t)-1; i--){
            this ->_maxHeapify(_comp, headers, i, count);
        }
    }
    
    void _maxHeapify(int (*_comp)(VECTOR_DATA,VECTOR_DATA),
                     struct _sortChunkHeader *headers, uint32_t root, uint32_t _count)
    {
        uint32_t left, right, largest;
        left = (root<<1) + 1;
        right = (root + 1) << 1;
        (left < _count && _comp(headers[root].minVal,
                                headers[left].minVal) < 0)?largest = left:largest = root;
        (right < _count && _comp(headers[largest].minVal,
                                 headers[right].minVal) < 0)?largest = right:largest = largest;
        if(largest != root){
            struct _sortChunkHeader tmp = headers[largest];
            headers[largest] = headers[root];
            headers[root] = tmp;
            this ->_maxHeapify(_comp, headers, largest, _count);
        }
        
    }
    
    /*uint32_t _findInsertHeader(struct _sortChunkHeader *headers, uint32_t count, VECTOR_DATA minInsert,
                               NSComparisonResult (*_comp)(VECTOR_DATA,VECTOR_DATA))
    {
        uint32_t base, top, curnt;
        base = 0; top = count;
        curnt = top >> 1;
        
        while(base != top - 1)
        {
            if(_comp(headers[curnt].minVal,minInsert) == NSOrderedAscending ||
               _comp(headers[curnt].minVal,minInsert) == NSOrderedSame){
                base = curnt;
                curnt = (top + base) >> 1;
            }else{
                top = curnt;
                curnt = (top + base) >> 1;
            }
        }
        return base;
    }*/
    
    
    inline VECTOR_DATA _replaceElementAtIndex(uint32_t index, VECTOR_DATA newData)
    {
        struct iterIndex indexInfo = _localIndexForGlobalIndex(index);
        return _chunksList[indexInfo.chunkIndex] ->replaceElementAtIndex(indexInfo.localIndex,newData);
    }
    
    /*void _globalHeapSort(NSComparisonResult (*_comp)(VECTOR_DATA,VECTOR_DATA))
    {
        uint32_t _count = this ->count();
        _globalBuildMaxHeap(_comp, _count);
        
        for(uint32_t i=_count - 1; i != 0; i--){
            VECTOR_DATA tmp = this ->_replaceElementAtIndex(i, this->elementAtIndex(0));
            this ->_replaceElementAtIndex(0,tmp);
            _globalMaxHeapify(_comp, 0, --_count);
        }
    }
    
    
    void _globalBuildMaxHeap(NSComparisonResult (*_comp)(VECTOR_DATA,VECTOR_DATA), uint32_t count)
    {
        for(uint32_t i = count >> 1; i != (uint32_t)-1; i--){
            this ->_globalMaxHeapify(_comp, i, count);
        }
    }
    
    void _globalMaxHeapify(NSComparisonResult (*_comp)(VECTOR_DATA,VECTOR_DATA),
                            uint32_t root, uint32_t _count)
    {
        uint32_t left, right, largest;
        left = (root<<1) + 1;
        right = (root + 1) << 1;

        
        VECTOR_DATA largestData, rootData;
        rootData = this ->elementAtIndex(root);
        largest = root;
        if(left < _count){
            largest = left;
            largestData = this->elementAtIndex(left);
            if(_comp(rootData,largestData) > 0){
                largest = root;
                largestData = rootData;
            }
        }
        if(right < _count){
            VECTOR_DATA tmp = this ->elementAtIndex(right);
            if(_comp(largestData, tmp) < 0){
                largest = right;
                largestData = tmp;
            }
        }
        
        
        if(largest != root){
            this ->_replaceElementAtIndex(root,largestData);
            this ->_replaceElementAtIndex(largest,rootData);
            
            this -> _globalMaxHeapify(_comp,largest,_count);
        }
        
    }*/
    
    bool _checkOrder()
    {
        uint32_t index = 1;
        uint32_t count = this ->count();
        VECTOR_DATA prev = this ->elementAtIndex(0);
        for(;index != count; index++){
            VECTOR_DATA curnt = this ->elementAtIndex(index);
            int cmpRes = _comparator(prev, curnt);
            if(cmpRes > 0)
                return false;
            prev = curnt;
        }
        return true;
    }
    
    bool _checkOrderCmp(int (*comp)(VECTOR_DATA,VECTOR_DATA, void *context), void *context)
    {
        uint32_t index = 1;
        uint32_t count = this ->count();
        VECTOR_DATA prev = this ->elementAtIndex(0);
        for(;index != count; index++){
            VECTOR_DATA curnt = this ->elementAtIndex(index);
            int cmpRes = comp(prev, curnt,context);
            if(cmpRes > 0)
                return false;
            prev = curnt;
        }
        return true;
    }
    
    void _initWithCopy(const CGRCircularVector& a)
    {
        _vectorStdChunkSize = a._vectorStdChunkSize;
        _chunkListSize = a._chunkListSize;
        
        
        _chunksList = (struct _vectorChunkDef **)malloc(sizeof(struct _vectorChunkDef *)*_chunkListSize);
        
        if(_chunksList == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
            //@throw e;
            CGRCircularVectorOutOfMemoryException exception;
            throw exception;
        }
        
        _vectorDirectory = (struct _dirElement *)malloc(sizeof(struct _dirElement)*_chunkListSize);
        if(_vectorDirectory == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector directory" userInfo:nil];
            //@throw e;
            CGRCircularVectorOutOfMemoryException exception;
            throw exception;
        }
        //Directory Initialization
        for(uint32_t i=0; i != _chunkListSize; i++){
            _vectorDirectory[i].minGlobalIndex = a._vectorDirectory[i].minGlobalIndex;
            _vectorDirectory[i].maxGlobalIndex= a._vectorDirectory[i].maxGlobalIndex;
        }
        
        _vectorDirectory[0].validEntry = a._vectorDirectory[0].validEntry;
        _lastDirectoryEntry = a._lastDirectoryEntry;
        
        
        _vectorCapacity = a._vectorCapacity;
        for(uint32_t i = 0; i != _chunkListSize; i++){
            _chunksList[i] = (struct _vectorChunkDef *)malloc(sizeof(struct _vectorChunkDef));
            if(_chunksList[i] == NULL){
                //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
                //@throw e;
                CGRCircularVectorOutOfMemoryException exception;
                throw exception;
            }
            _chunksList[i] ->init(a._chunksList[i] ->_chunkSize);
            _chunksList[i] ->_nextFreeIndex = a._chunksList[i] ->_nextFreeIndex;
            _chunksList[i] ->_comparator = a._chunksList[i] ->_comparator;
            for(uint32_t j=0; j != a._chunksList[i] ->_chunkSize; j++){
                _chunksList[i] ->_chunkData[j] = a._chunksList[i] ->_chunkData[j];
            }
            _vectorCapacity += _vectorStdChunkSize;
            if(_vectorCapacity < a._vectorSize)
                continue;
            break;
        }
        _vectorSize = a._vectorSize;
        _vectorIterIndex = a._vectorIterIndex;
        _vectorCurntIterChunk = a._vectorCurntIterChunk;
        _vectorCurntAddChunk = a._vectorCurntAddChunk;
        _comparator = a._comparator;
    }
    
#pragma mark -
    
public:
    
#pragma mark Constructors
    CGRCircularVector()
    {
        _init(500, 500);
    }
    ~CGRCircularVector()
    {
        for(uint32_t i=0; i != _chunkListSize; i++){
            if(_chunksList[i] != NULL){
                _chunksList[i]->release();
                free(_chunksList[i]);
            }
            
        }
        free(_chunksList);
        free(_vectorDirectory);
    }
    
    CGRCircularVector(uint32_t size)
    {
        if(size < 16){
            _init(10,10);
            return;
        }
        uint32_t chunkSize = size >> 2;
        _init(size, chunkSize);
    }
    
    CGRCircularVector(uint32_t size, uint32_t chunkSize)
    {
        _init(size,chunkSize);
    }
    
    //Copy constructor
    CGRCircularVector(const CGRCircularVector& a)
    {
        _initWithCopy(a);
    }
    //Copy assignment
    CGRCircularVector& operator=(const CGRCircularVector& a)
    {
        _initWithCopy(a);
        return this;
    }
    
    VECTOR_DATA& operator[](size_t index)
    {
        return this ->elementAtIndex(index);
    }
    
#pragma mark -
#pragma mark Basic operations
    
    uint32_t add(VECTOR_DATA data)
    {
        
        /*struct iterIndex indices = _localIndexForGlobalIndex(this ->count());
        
        if(indices.chunkIndex == _chunkListSize)
            _increaseVector();
        
        this ->insertAtIndex(data, this ->count());
        return _vectorSize-1;*/
        
        uint32_t actualIndex = _chunksList[_vectorCurntAddChunk] -> addIntoChunk(data);
        while(actualIndex == -1 && _vectorCurntAddChunk < _chunkListSize){
            //We increase the chunk index
            _vectorCurntAddChunk++;
            if(_vectorCurntAddChunk == _chunkListSize)
                _increaseVector();
            actualIndex = _chunksList[_vectorCurntAddChunk] ->addIntoChunk(data);
        }
        if(_vectorDirectory[_vectorCurntAddChunk].validEntry){
            _vectorDirectory[_vectorCurntAddChunk].maxGlobalIndex++;
        }else{
            _vectorDirectory[_vectorCurntAddChunk].minGlobalIndex = _vectorDirectory[_vectorCurntAddChunk-1].maxGlobalIndex;
            _vectorDirectory[_vectorCurntAddChunk].maxGlobalIndex = _vectorDirectory[_vectorCurntAddChunk].minGlobalIndex+1;
            _vectorDirectory[_vectorCurntAddChunk].validEntry = true;
            _lastDirectoryEntry++;
        }
        
        _vectorSize++;
        return _vectorSize - 1;
        
        /*
        if(!this ->count())
            this ->insertAtIndex(data, 0);
        else
            this ->insertAtIndex(data, this ->count());
        return _vectorSize - 1;*/
    }
    
    void insertAtIndex(VECTOR_DATA data, uint32_t index)
    {
        if(index > _vectorSize){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"Index out of range of Vector" userInfo:nil];
            //@throw e;
            CGRCircularVectorIndexException exception;
            throw exception;
        }
        
        /*if(index == this ->count()){
            this ->add(data);
            return;
        }*/
            
        
        struct iterIndex indices = _localIndexForGlobalIndex(index);
        uint32_t nextIndex = indices.localIndex;
        uint32_t chunkIndex = indices.chunkIndex;
        
        if(chunkIndex == _chunkListSize){
            //To be further safe :)
            CGRCircularVectorIndexException exception;
            throw exception;
        }
        if(_chunksList[chunkIndex]->chunkSize() > _vectorStdChunkSize << 1){
            //The chunk spilled, so we need to split it in two new chunks
            _chunkSpilled(chunkIndex);
            if(nextIndex > _vectorStdChunkSize){
                chunkIndex++;
                nextIndex -= _vectorStdChunkSize;
            }
        }
        _chunksList[chunkIndex]->insertIntoChunk(data, nextIndex);
        
        //Update the directory
        _vectorDirectory[chunkIndex].maxGlobalIndex++;
        for(uint32_t i=chunkIndex+1; i != _chunkListSize;i++){
            if(_vectorDirectory[i].validEntry){
                _vectorDirectory[i].minGlobalIndex++;
                _vectorDirectory[i].maxGlobalIndex++;
            }
        }
        
        _vectorSize++;
        _modIterIndexForOperation(1, index);
        
    }
    
    VECTOR_DATA removeAtIndex(uint32_t index)
    {
        if(index >= _vectorSize){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"Index out of range of Vector" userInfo:nil];
            //@throw e;
            CGRCircularVectorIndexException exception;
            throw exception;
        }
        
        struct iterIndex indices = _localIndexForGlobalIndex(index);
        uint32_t nextIndex = indices.localIndex;
        uint32_t chunkIndex = indices.chunkIndex;
        
        if(chunkIndex == _chunkListSize){
            //To be further safe :)
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"Index out of range of Vector" userInfo:nil];
            //@throw e;
            CGRCircularVectorIndexException exception;
            throw exception;
        }
        _vectorSize--;
        _modIterIndexForOperation(2, index);
        
        //Modify the directory
        _vectorDirectory[chunkIndex].maxGlobalIndex--;
        
        
        
        for(uint32_t i=chunkIndex+1; i != _chunkListSize;i++){
            if(_vectorDirectory[i].validEntry){
                _vectorDirectory[i].minGlobalIndex--;
                _vectorDirectory[i].maxGlobalIndex--;
            }
        }
        
        VECTOR_DATA retData = _chunksList[chunkIndex]->removeAtIndex(nextIndex);
        //chunkIndex != 0 &&
        if(_vectorDirectory[chunkIndex].maxGlobalIndex == _vectorDirectory[chunkIndex].minGlobalIndex){
            if(!_vectorSize){
                //Last chunk
                _vectorDirectory[0].validEntry = true;
                _vectorDirectory[0].minGlobalIndex = 0;
                _vectorDirectory[0].maxGlobalIndex = 0;
                _lastDirectoryEntry = 1;
                _vectorSize = 0;
                _vectorIterIndex = 0;
                _vectorCurntIterChunk = 0;
                _vectorCurntAddChunk = 0;
                return retData;
            }
            //The chunk has become empty so we 'shift' it to the end
            _vectorChunkDef *emptyChunk = _chunksList[chunkIndex];
            for (uint32_t i=chunkIndex + 1; i != _chunkListSize; i++) {
                _vectorDirectory[i-1] = _vectorDirectory[i];
                //Now shift the actual chunks
                _chunksList[i-1] = _chunksList[i];
            }
            _vectorDirectory[_chunkListSize - 1].validEntry = false;
            _vectorDirectory[_chunkListSize - 1].minGlobalIndex = 0;
            _vectorDirectory[_chunkListSize - 1].maxGlobalIndex = 0;
            
            _chunksList[_chunkListSize-1] = emptyChunk;
            _lastDirectoryEntry--;
            free(_chunksList[_chunkListSize-1]);
            _chunkListSize--;
            _vectorCurntAddChunk--;
            
        }
        return retData;
    }
    
    void removeAll()
    {
        uint32_t nElements = this ->count();
        while(nElements != 0)
        {
            this ->removeAtIndex(nElements-1);
            nElements--;
        }
    }
    
    
    VECTOR_DATA elementAtIndex(uint32_t index)
    {
        if(index >= _vectorSize){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"Index out of range of Vector" userInfo:nil];
            //@throw e;
            CGRCircularVectorIndexException exception;
            throw exception;
        }
        struct iterIndex indices = _localIndexForGlobalIndex(index);
        uint32_t nextIndex = indices.localIndex;
        uint32_t chunkIndex = indices.chunkIndex;
        return _chunksList[chunkIndex]->elementAtIndex(nextIndex);
    }
    
    uint32_t count()
    {
        return _vectorSize;
    }
    
    void setComparator( int (*comp)(VECTOR_DATA,VECTOR_DATA))
    {
        _comparator = comp;
    }
    
#pragma mark -
    
#pragma mark Circula Iterator
    
    void startIteratingFromIndex(uint32_t index){
        if(index < _vectorSize)
            _vectorIterIndex = index;
        struct iterIndex local = _localIndexForGlobalIndex(_vectorIterIndex);
        _vectorCurntIterChunk = local.chunkIndex;
        _vectorCurntIterIndex = local.localIndex;
    }
    
    void startIteratingFromElement(VECTOR_DATA element)
    {
        if(_comparator == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"No comparator set for Vector. Use startIteratingFromElementWithComparator instead or set a comparator for the vector" userInfo:nil];
            //@throw e;
            CGRCircularVectorNoComparatorException exception;
            throw exception;
        }
        uint32_t vectorCount = this ->count();
        uint32_t curntChunk = 0;
        uint32_t curntIndex = 0;
        for(uint32_t i=0; i != vectorCount; i++){
            if(curntIndex == _chunksList[curntChunk] ->chunkSize()){
                curntIndex = 0;
                curntChunk++;
            }
            if (_comparator(_chunksList[curntChunk]->elementAtIndex(curntIndex),element) == 0) {
                this ->startIteratingFromIndex(i);
                return;
            }
            curntIndex++;
        }
        //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"No element to start the iteration found." userInfo:nil];
        //@throw e;
        CGRCircularvectorNoStartElementFound exception;
        throw exception;
    }
    
    uint32_t curntIterationIndex()
    {
        return _vectorIterIndex;
    }
    
    void startIteratingFromElementWithComparator(VECTOR_DATA element, int (*comp)(VECTOR_DATA,VECTOR_DATA))
    {
        if(comp == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"Comparator can't be NULL at startIteratingFromElementWithComparator" userInfo:nil];
            //@throw e;
            CGRCircularVectorNoComparatorException exception;
            throw exception;
        }
        uint32_t vectorCount = this ->count();
        uint32_t curntChunk = 0;
        uint32_t curntIndex = 0;
        for(uint32_t i=0; i != vectorCount; i++){
            if(curntIndex == _chunksList[curntChunk]->chunkSize()){
                curntIndex = 0;
                curntChunk++;
            }
            if (comp(_chunksList[curntChunk]->elementAtIndex(curntIndex),element) == 0) {
                this ->startIteratingFromIndex(i);
                return;
            }
            curntIndex++;
        }
        //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"No element to start the iteration found" userInfo:nil];
        //@throw e;
        CGRCircularvectorNoStartElementFound exception;
        throw exception;
    }
    
    VECTOR_DATA curntItem()
    {
        return _chunksList[_vectorCurntIterChunk]->elementAtIndex(_vectorCurntIterIndex);
    }
    
    VECTOR_DATA nextItem()
    {
        ++_vectorIterIndex %= this ->count();
        _vectorCurntIterIndex++;
        if(_vectorCurntIterIndex == _chunksList[_vectorCurntIterChunk]->chunkSize()){
            _vectorCurntIterChunk++;
            if(_vectorCurntIterChunk == _chunkListSize){
                _vectorCurntIterChunk = 0;
            }else{
                //Check if the chunk is not empty
                if(!_chunksList[_vectorCurntIterChunk]->chunkSize()){
                    _vectorCurntIterChunk = 0; //Reset it.. we have spare room
                }
            }
            _vectorCurntIterIndex = 0;
        }
        return _chunksList[_vectorCurntIterChunk]->elementAtIndex(_vectorCurntIterIndex);
    }
    
    VECTOR_DATA prevItem()
    {
        if(_vectorIterIndex == 0){
            _vectorIterIndex = this ->count() - 1;
            _vectorCurntIterChunk = _chunkListSize - 1;
            while(!_chunksList[_vectorCurntIterChunk]->chunkSize()){
                _vectorCurntIterChunk--;
            }
            _vectorCurntIterIndex = _chunksList[_vectorCurntIterChunk]->chunkSize() - 1;
        }else{
            _vectorIterIndex--;
            if(_vectorCurntIterIndex == 0)
            {
                _vectorCurntIterChunk--;
                _vectorCurntIterIndex = _chunksList[_vectorCurntIterChunk]->chunkSize() - 1;
            }else{
                _vectorCurntIterIndex--;
            }
        }
        return _chunksList[_vectorCurntIterChunk]->elementAtIndex(_vectorCurntIterIndex);
    }
#pragma mark -
    
#pragma mark Sorting
    
    
    void sortVector()
    {
        if(_comparator == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"No comparator set for Vector. Use sortWithComparator instead or set a comparator for the vector" userInfo:nil];
            //@throw e;
            CGRCircularVectorNoComparatorException exception;
            throw exception;
        }
        //this ->_globalHeapSort(_comparator);
        struct _sortChunkHeader *headers = (struct _sortChunkHeader *)malloc(sizeof(struct _sortChunkHeader)*_chunkListSize);
        if(headers == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"Not enough memory for sorting" userInfo:nil];
            //@throw e;
            CGRCircularVectorOutOfMemoryException exception;
            throw exception;
        }
        
        
        
        uint32_t headersIndex = 0;
        //Sort each chunk with the comparator
        for(int i=0; i != _chunkListSize; i++){
            if(!_chunksList[i]->chunkSize())
                continue;
            _chunksList[i]->sortUsingComparator(_comparator);
            
            headers[headersIndex].minVal = _chunksList[i]->_chunkData[0];
            headers[headersIndex].maxVal = _chunksList[i]->_chunkData[_chunksList[i]->chunkSize() - 1];
            headers[headersIndex].ptr = _chunksList[i];
            headersIndex++;
        }
        if(headersIndex == 1){
            //We are finished
            free(headers);
            return;
        }
        //Sort the headers with respect to the min value
        _heapSort(_comparator, headers, headersIndex);
        //Re-arrange the chunksList with respect to headers
        for(uint32_t i=0; i != headersIndex; i++){
            _chunksList[i] = headers[i].ptr;
        }
        
        //VECTOR_DATA *tmpQueue = (VECTOR_DATA *)malloc(sizeof(VECTOR_DATA) * _chunksList[0]->_chunkSize);
        //uint32_t tmpQueueSize =_chunksList[0]->_chunkSize;
        uint32_t tmpQueueSize = 0;
        VECTOR_DATA *tmpQueue;
        for(uint32_t ci = 0; ci != headersIndex; ci++){
            if(_chunksList[ci] ->chunkSize() > tmpQueueSize){
                tmpQueueSize = _chunksList[ci] ->chunkSize();
            }
        }
        tmpQueueSize += 1;
        tmpQueue = (VECTOR_DATA *)malloc(sizeof(VECTOR_DATA) * tmpQueueSize);
        uint32_t tmpQueueNextFree = 0;
        uint32_t tmpQueueTopMin = 0;
        //Once the headers are sorted.. start assemble the intervals
        for(uint32_t i=1; i != headersIndex; i++){
            
            tmpQueueNextFree = 0;
            tmpQueueTopMin = -1;
            
            uint32_t headerMinIndex = 0;
            uint32_t chunkMinIndex;
            
            while(headerMinIndex != i){
                chunkMinIndex = headers[headerMinIndex].ptr ->insertionIndexForElement(_comparator,headers[i].minVal);
                if(chunkMinIndex != headers[headerMinIndex].ptr ->chunkSize())
                    break;
                headerMinIndex++;
            }
            //_findInsertHeader(headers, i, headers[i].minVal, _comparator);
            //uint32_t chunkMinIndex = headers[headerMinIndex].ptr ->insertionIndexForElement(_comparator,headers[i].minVal);
            
            //if(chunkMinIndex == _chunksList[headerMinIndex] ->chunkSize())
            if(headerMinIndex == i)
                continue;
            
            
            uint32_t localIndex = 0;
            uint32_t localSize = _chunksList[i] ->chunkSize();
            //Merge the i chunk with the i-1 already fully sorted chunks
            
            while(localIndex != localSize && headerMinIndex != i){
                if(tmpQueueTopMin != -1 &&
                   _comparator(tmpQueue[tmpQueueTopMin],_chunksList[i] ->_chunkData[localIndex]) < 0){
                    
                    tmpQueue[tmpQueueNextFree] = _chunksList[headerMinIndex] ->_chunkData[chunkMinIndex];
                    _chunksList[headerMinIndex] ->_chunkData[chunkMinIndex] = tmpQueue[tmpQueueTopMin];
                    ++tmpQueueTopMin %= tmpQueueSize;
                    ++tmpQueueNextFree %= tmpQueueSize;
                    
                }else{
                    
                    tmpQueue[tmpQueueNextFree] = _chunksList[headerMinIndex] ->_chunkData[chunkMinIndex];
                    _chunksList[headerMinIndex] ->_chunkData[chunkMinIndex] =
                    _chunksList[i] ->_chunkData[localIndex++];
                    if(tmpQueueTopMin == -1){
                        tmpQueueTopMin = 0;
                    }
                    ++tmpQueueNextFree %= tmpQueueSize;
                }
                chunkMinIndex++;
                if(chunkMinIndex == _chunksList[headerMinIndex] ->chunkSize()){
                    chunkMinIndex=0;
                    headerMinIndex++;
                }
            }
            /*
            for(uint32_t j = 0; j != i; j++){
                for(uint32_t k=1; k != _chunksList[j] ->chunkSize(); k++){
                    if(_comparator(_chunksList[j] ->_chunkData[k],
                                   _chunksList[j] ->_chunkData[k-1]) == NSOrderedAscending){
                        NSException *e = [NSException exceptionWithName:@"OppsException" reason:@"Oops" userInfo:nil];
                        @throw e;
                    }
                }
            }
             */
            
            if(localIndex != localSize){
                //We haven't finished :)
                //We are at i chunk and some of the elements are in their 'final' position, so we dump the queue into the chunk
                while(tmpQueueTopMin != tmpQueueNextFree){
                    
                    if(localIndex == localSize ||
                       _comparator(tmpQueue[tmpQueueTopMin],_chunksList[i] ->_chunkData[localIndex]) < 0){
                        
                        _chunksList[headerMinIndex] ->_chunkData[chunkMinIndex] = tmpQueue[tmpQueueTopMin];
                        ++tmpQueueTopMin %= tmpQueueSize;
                    }else{
                        
                        _chunksList[headerMinIndex] ->_chunkData[chunkMinIndex] =
                        _chunksList[i] ->_chunkData[localIndex++];
                        
                    }
                    chunkMinIndex++;
                }
                
            }else{
                //localIndex == localSize
                //We still need to shift all the values
                //Arrange if tmpQueueTopMin > tmpQueueNextFree
                if(tmpQueueTopMin > tmpQueueNextFree){
                    VECTOR_DATA *tmpArray = (VECTOR_DATA *)malloc(sizeof(VECTOR_DATA)* (tmpQueueSize - tmpQueueTopMin));
                    if(tmpArray == NULL){
                        free(tmpQueue);
                        free(headers);
                        //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorNotEnoughtMemory" reason:@"Not enough memory for sorting" userInfo:nil];
                        //@throw e;
                        CGRCircularVectorOutOfMemoryException exception;
                        throw exception;
                    }
                    memcpy(tmpArray, tmpQueue + tmpQueueTopMin, sizeof(VECTOR_DATA)*(tmpQueueSize - tmpQueueTopMin));
                    //Shift the elements from 0 to tmpQueueNextFree-1 tmpQueueSize - tmpQueueTopMin places to the right
                    uint32_t displacement = tmpQueueSize - tmpQueueTopMin;
                    for(uint32_t i = tmpQueueNextFree-1; i != -1; i--){
                        tmpQueue[i+displacement] = tmpQueue[i];
                    }
                    memcpy(tmpQueue, tmpArray, sizeof(VECTOR_DATA)*displacement);
                    free(tmpArray);
                    tmpQueueTopMin = 0;
                    tmpQueueNextFree += displacement;
                }
                while(headerMinIndex < i){
                    if(_comparator(tmpQueue[tmpQueueTopMin],_chunksList[headerMinIndex] ->_chunkData[chunkMinIndex]) < 0){
                        
                        tmpQueue[tmpQueueNextFree] = _chunksList[headerMinIndex] ->_chunkData[chunkMinIndex];
                        _chunksList[headerMinIndex] ->_chunkData[chunkMinIndex] = tmpQueue[tmpQueueTopMin];
                        ++tmpQueueTopMin %= tmpQueueSize;
                        ++tmpQueueNextFree %= tmpQueueSize;
                        
                    }
                    chunkMinIndex++;
                    if(chunkMinIndex == _chunksList[headerMinIndex] ->chunkSize()){
                        chunkMinIndex=0;
                        headerMinIndex++;
                    }
                }
                //Now just dump
                while(tmpQueueTopMin != tmpQueueNextFree){
    
                    _chunksList[headerMinIndex] ->_chunkData[chunkMinIndex] = tmpQueue[tmpQueueTopMin];
                    ++tmpQueueTopMin %= tmpQueueSize;
                    
                    chunkMinIndex++;
                }
                
            }
            
            /*
            for(uint32_t j = 0; j != i+1; j++){
                for(uint32_t k=1; k != _chunksList[j] ->chunkSize(); k++){
                    if(_comparator(_chunksList[j] ->_chunkData[k],
                                   _chunksList[j] ->_chunkData[k-1]) == NSOrderedAscending){
                        NSException *e = [NSException exceptionWithName:@"OppsException" reason:@"Oops" userInfo:nil];
                        @throw e;
                    }
                }
            }
             */
            
            //printf("h");
            
            
        }
        
        
        free(tmpQueue);
        free(headers);
        
        
        //Re-arrange the directory
        uint32_t numOfChunks = 0;
        for(; numOfChunks != _chunkListSize && _chunksList[numOfChunks] ->chunkSize() != 0; numOfChunks++);
        uint32_t minGlobal = 0;
        for(uint32_t i=0; i != numOfChunks; i++){
            _vectorDirectory[i].validEntry = true;
            _vectorDirectory[i].minGlobalIndex = minGlobal;
            minGlobal += _chunksList[i] ->chunkSize();
            _vectorDirectory[i].maxGlobalIndex = minGlobal;
        }
        
    }
    
    //Looks for element in the vector using binary search
    //If checkOrder is set then checks that the vector is sorted
    bool BSContains(VECTOR_DATA element, bool checkOrder)
    {
        if(_comparator == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"No comparator set for Vector. Use sortWithComparator instead or set a comparator for the vector" userInfo:nil];
            //@throw e;
            CGRCircularVectorNoComparatorException exception;
            throw exception;
        }
        if(checkOrder && !_checkOrder()){
            CGRCircularVectorNoSortedException exception;
            throw exception;
        }
            
        uint32_t base, limit, curnt;
        base = 0;
        limit = _vectorSize;
        if(!limit)
            return false;
        
        curnt = limit;
        
        while(base != limit - 1)
        {
            curnt = base + ((limit - base) >> 1);
            int cmpRes = _comparator(element, this -> elementAtIndex(curnt));
            if (!cmpRes) {
                return true;
            }
            if (cmpRes < 0) {
                limit = curnt;
            }else{
                base = curnt;
            }
        }
        
        if(limit != _vectorSize){
            if(!_comparator(element, this -> elementAtIndex(base)))
                return true;
            return false;
        }
        return false;
    }
    
    //Returns the index of the element in the vector (if any)
    //If the element is not found, then CGRCircularVectorNoElementException is thrown
    uint32_t BSIndexOfElement(VECTOR_DATA element, bool checkOrder)
    {
        if(_comparator == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"No comparator set for Vector. Use sortWithComparator instead or set a comparator for the vector" userInfo:nil];
            //@throw e;
            CGRCircularVectorNoComparatorException exception;
            throw exception;
        }
        if(checkOrder && !_checkOrder()){
            CGRCircularVectorNoSortedException exception;
            throw exception;
        }
        
        uint32_t base, limit, curnt;
        base = 0;
        limit = _vectorSize;
        if (!limit) {
            throw CGRCircularVectorNoElementException();
        }
        curnt = limit;
        
        while(base != limit - 1)
        {
            curnt = base + ((limit - base) >> 1);
            int cmpRes = _comparator(element, this -> elementAtIndex(curnt));
            if (!cmpRes) {
                return curnt;
            }
            if (cmpRes < 0) {
                limit = curnt;
            }else{
                base = curnt;
            }
        }
        
        if(limit != _vectorSize){
            if(!_comparator(element, this -> elementAtIndex(base)))
                return base;
        }
        throw CGRCircularVectorNoElementException();
    }
    
    //Inserts a new element in the vector usign binary search to find its place
    //If checkOrder is set then checks that the vector is sorted
    uint32_t BSInserts(VECTOR_DATA element, bool checkOrder)
    {
        if(_comparator == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"No comparator set for Vector. Use sortWithComparator instead or set a comparator for the vector" userInfo:nil];
            //@throw e;
            CGRCircularVectorNoComparatorException exception;
            throw exception;
        }
        if(checkOrder && !_checkOrder()){
            CGRCircularVectorNoSortedException exception;
            throw exception;
        }
        uint32_t base, limit, curnt;
        base = 0;
        limit = _vectorSize;
        if(!limit){
            this ->insertAtIndex(element, limit);
            return 0;
        }
        curnt = limit;
        
        while(base != limit - 1)
        {
            curnt = base + ((limit - base) >> 1);
            int cmpRes = _comparator(element, this -> elementAtIndex(curnt));
            if (!cmpRes) {
                return curnt; //Element is already in the vector
            }
            if (cmpRes < 0) {
                limit = curnt;
            }else{
                base = curnt;
            }
        }
        this ->insertAtIndex(element, limit);
        return limit;
    }
    
    //Returns the index of the element in the vector (if any) using a provided comparator
    //If the element is not found, then CGRCircularVectorNoElementException is thrown
    uint32_t BSIndexOfElementCmp(VECTOR_DATA element, bool checkOrder,int (*comp)(VECTOR_DATA,VECTOR_DATA, void *context), void *context)
    {
        if(comp == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"No comparator set for Vector. Use sortWithComparator instead or set a comparator for the vector" userInfo:nil];
            //@throw e;
            CGRCircularVectorNoComparatorException exception;
            throw exception;
        }
        if(checkOrder && !_checkOrderCmp(comp,context)){
            CGRCircularVectorNoSortedException exception;
            throw exception;
        }
        
        uint32_t base, limit, curnt;
        base = 0;
        limit = _vectorSize;
        if(!limit)
            throw CGRCircularVectorNoElementException();
        
        curnt = limit;
        
        while(base != limit - 1)
        {
            curnt = base + ((limit - base) >> 1);
            int cmpRes = comp(element, this -> elementAtIndex(curnt),context);
            if (!cmpRes) {
                return curnt;
            }
            if (cmpRes < 0) {
                limit = curnt;
            }else{
                base = curnt;
            }
        }
        
        if(limit != _vectorSize){
            if(!comp(element, this -> elementAtIndex(base),context))
                return base;
        }
        throw CGRCircularVectorNoElementException();
    }
    
    bool BSContainsCmp(VECTOR_DATA element, bool checkOrder, int (*comp)(VECTOR_DATA,VECTOR_DATA, void *context), void *context)
    {
        if(comp == NULL){
            //NSException *e = [NSException exceptionWithName:@"CGRCircularVectorIndexException" reason:@"No comparator set for Vector. Use sortWithComparator instead or set a comparator for the vector" userInfo:nil];
            //@throw e;
            CGRCircularVectorNoComparatorException exception;
            throw exception;
        }
        if(checkOrder && !_checkOrderCmp(comp,context)){
            CGRCircularVectorNoSortedException exception;
            throw exception;
        }
        
        uint32_t base, limit, curnt;
        base = 0;
        limit = _vectorSize;
        if(!limit)
            return false;
        curnt = limit;
        
        while(base != limit - 1)
        {
            curnt = base + ((limit - base) >> 1);
            int cmpRes = comp(element, this -> elementAtIndex(curnt),context);
            if (!cmpRes) {
                return true;
            }
            if (cmpRes < 0) {
                limit = curnt;
            }else{
                base = curnt;
            }
        }
        
        if(limit != _vectorSize){
            if(!comp(element, this -> elementAtIndex(base),context))
                return true;
            return false;
        }
        return false;
    }
    
    
#pragma mark -
    
};
#endif
