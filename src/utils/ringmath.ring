# Ring Math Library for Neural Networks - FastPro Optimized
Load "stdlibcore.ring"
Load "math.ring"
Load "fastpro.ring"

Class Matrix 
    # المتغيرات العامة
    nRows = 0
    nCols = 0
    aData = []
    
    func init(nP_Rows, nP_Cols)
        nRows = nP_Rows
        nCols = nP_Cols
        aData = list(nRows * nCols)
    
    func get(nI, nJ)
        return aData[(nI-1) * nCols + nJ]
    
    func set(nI, nJ, nValue)
        aData[(nI-1) * nCols + nJ] = nValue
    
    func multiply(oOther)
        if nCols != oOther.nRows
            return NULL
        ok

        # Convert to 2D arrays for FastPro processing
        aMatrix1 = to2DArray()
        aMatrix2 = oOther.to2DArray()

        # Use FastPro matrix multiplication
        aResult = updateList(aMatrix1, :mul, :matrix, aMatrix2)

        # Convert back to Matrix object
        oResult = new Matrix(nRows, oOther.nCols)
        oResult.from2DArray(aResult)

        return oResult

    # FastPro Helper Methods
    func to2DArray()
        aResult = []
        for i = 1 to nRows
            aRow = []
            for j = 1 to nCols
                add(aRow, get(i, j))
            next
            add(aResult, aRow)
        next
        return aResult

    func from2DArray(aArray)
        nRows = len(aArray)
        nCols = len(aArray[1])
        aData = list(nRows * nCols)

        for i = 1 to nRows
            for j = 1 to nCols
                set(i, j, aArray[i][j])
            next
        next

    func add(oOther)
        if nRows != oOther.nRows or nCols != oOther.nCols
            return NULL
        ok

        # Use FastPro for matrix addition
        aMatrix1 = to2DArray()
        aMatrix2 = oOther.to2DArray()
        aResult = updateList(aMatrix1, :add, :matrix, aMatrix2)

        oResult = new Matrix(nRows, nCols)
        oResult.from2DArray(aResult)

        return oResult
    
    func transpose()
        # Use FastPro for matrix transpose
        aMatrix = to2DArray()
        aResult = updateList(aMatrix, :transpose, :matrix)

        oResult = new Matrix(nCols, nRows)
        oResult.from2DArray(aResult)

        return oResult

    

Class Activations 
    func relu(oX)
        # Use FastPro for ReLU activation
        aMatrix = oX.to2DArray()
        aResult = updateList(aMatrix, :relu, :matrix)

        oResult = new Matrix(oX.nRows, oX.nCols)
        oResult.from2DArray(aResult)

        return oResult
    
    func softmax(oX)
        # Use FastPro for Softmax activation
        aMatrix = oX.to2DArray()
        aResult = updateList(aMatrix, :softmax, :matrix)

        oResult = new Matrix(oX.nRows, oX.nCols)
        oResult.from2DArray(aResult)

        return oResult

    private
        # متغيرات خاصة إذا لزم الأمر

Class Random 
    func xavier_init(nFanIn, nFanOut)
        oResult = new Matrix(nFanIn, nFanOut)
        nLimit = sqrt(6.0 / (nFanIn + nFanOut))
        
        for i = 1 to nFanIn
            for j = 1 to nFanOut
                nRand = random(-nLimit, nLimit)
                oResult.set(i, j, nRand)
            next
        next
        
        return oResult
    
    func random(nMin, nMax)
        return nMin + (nMax - nMin) * random(0, 1)

    private
        # متغيرات خاصة إذا لزم الأمر
