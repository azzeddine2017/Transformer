# Ring Math Library for Neural Networks
Load "stdlibcore.ring"
Load "math.ring"

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
        
        oResult = new Matrix(nRows, oOther.nCols)
        
        for i = 1 to nRows
            for j = 1 to oOther.nCols
                nSum = 0
                for k = 1 to nCols
                    nSum += get(i, k) * oOther.get(k, j)
                next
                oResult.set(i, j, nSum)
            next
        next
        
        return oResult
    
    func add(oOther)
        if nRows != oOther.nRows or nCols != oOther.nCols
            return NULL
        ok
        
        oResult = new Matrix(nRows, nCols)
        
        for i = 1 to nRows
            for j = 1 to nCols
                oResult.set(i, j, get(i, j) + oOther.get(i, j))
            next
        next
        
        return oResult
    
    func transpose()
        oResult = new Matrix(nCols, nRows)
        
        for i = 1 to nRows
            for j = 1 to nCols
                oResult.set(j, i, get(i, j))
            next
        next
        
        return oResult

    

Class Activations 
    func relu(oX)
        oResult = new Matrix(oX.nRows, oX.nCols)
        
        for i = 1 to oX.nRows
            for j = 1 to oX.nCols
                nValue = oX.get(i, j)
                oResult.set(i, j, max(0, nValue))
            next
        next
        
        return oResult
    
    func softmax(oX)
        oResult = new Matrix(oX.nRows, oX.nCols)
        
        for i = 1 to oX.nRows
            # حساب القيمة القصوى للصف
            nMaxVal = oX.get(i, 1)
            for j = 2 to oX.nCols
                nMaxVal = max(nMaxVal, oX.get(i, j))
            next
            
            # حساب المجموع للتطبيع
            nSum = 0
            for j = 1 to oX.nCols
                nSum += exp(oX.get(i, j) - nMaxVal)
            next
            
            # حساب القيم النهائية
            for j = 1 to oX.nCols
                nValue = exp(oX.get(i, j) - nMaxVal) / nSum
                oResult.set(i, j, nValue)
            next
        next
        
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
