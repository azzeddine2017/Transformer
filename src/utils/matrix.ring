Load "stdlibcore.ring"
Load "math.ring"

# فئة المصفوفات للعمليات الحسابية
Class Matrix
    # البيانات الأساسية
    aData = []      # مصفوفة ثنائية الأبعاد
    nRows = 0       # عدد الصفوف
    nCols = 0       # عدد الأعمدة
    
    func init(p1, p2)
        if type(p1) = "NUMBER" and type(p2) = "NUMBER"
            # إنشاء مصفوفة جديدة
            nRows = p1
            nCols = p2
            initializeZeros()
        elseif type(p1) = "LIST"
            # إنشاء مصفوفة من قائمة
            aData = p1
            nRows = len(p1)
            nCols = len(p1[1])
        ok
        return self
        
    func initializeZeros
        aData = list(nRows)
        for i = 1 to nRows
            aData[i] = list(nCols)
            for j = 1 to nCols
                aData[i][j] = 0
            next
        next
        
    func randomize(fMin, fMax)
        for i = 1 to nRows
            for j = 1 to nCols
                aData[i][j] = random(fMin, fMax)
            next
        next
        return self
        
    func add(oOther)
        if nRows != oOther.nRows or nCols != oOther.nCols
            raise("أبعاد المصفوفات غير متطابقة للجمع")
        ok
        
        result = new Matrix(nRows, nCols)
        for i = 1 to nRows
            for j = 1 to nCols
                result.aData[i][j] = aData[i][j] + oOther.aData[i][j]
            next
        next
        return result
        
    func subtract(oOther)
        if nRows != oOther.nRows or nCols != oOther.nCols
            raise("أبعاد المصفوفات غير متطابقة للطرح")
        ok
        
        result = new Matrix(nRows, nCols)
        for i = 1 to nRows
            for j = 1 to nCols
                result.aData[i][j] = aData[i][j] - oOther.aData[i][j]
            next
        next
        return result
        
    func multiply(oOther)
        if nCols != oOther.nRows
            raise("أبعاد المصفوفات غير متطابقة للضرب")
        ok
        
        result = new Matrix(nRows, oOther.nCols)
        for i = 1 to nRows
            for j = 1 to oOther.nCols
                sum = 0
                for k = 1 to nCols
                    sum += aData[i][k] * oOther.aData[k][j]
                next
                result.aData[i][j] = sum
            next
        next
        return result
        
    func transpose
        result = new Matrix(nCols, nRows)
        for i = 1 to nRows
            for j = 1 to nCols
                result.aData[j][i] = aData[i][j]
            next
        next
        return result
        
    func scale(scalar)
        result = new Matrix(nRows, nCols)
        for i = 1 to nRows
            for j = 1 to nCols
                result.aData[i][j] = aData[i][j] * scalar
            next
        next
        return result
        
    func elementWiseMultiply(oOther)
        if nRows != oOther.nRows or nCols != oOther.nCols
            raise("أبعاد المصفوفات غير متطابقة للضرب العنصري")
        ok
        
        result = new Matrix(nRows, nCols)
        for i = 1 to nRows
            for j = 1 to nCols
                result.aData[i][j] = aData[i][j] * oOther.aData[i][j]
            next
        next
        return result
        
    func softmax
        result = new Matrix(nRows, nCols)
        for i = 1 to nRows
            # البحث عن أكبر قيمة في الصف
            maxVal = aData[i][1]
            for j = 2 to nCols
                if aData[i][j] > maxVal
                    maxVal = aData[i][j]
                ok
            next
            
            # حساب المجموع
            sum = 0
            for j = 1 to nCols
                sum += exp(aData[i][j] - maxVal)
            next
            
            # حساب القيم النهائية
            for j = 1 to nCols
                result.aData[i][j] = exp(aData[i][j] - maxVal) / sum
            next
        next
        return result
        
    func save(oFile)
        fwrite(oFile, str(nRows) + "," + str(nCols) + nl)
        for i = 1 to nRows
            cLine = ""
            for j = 1 to nCols
                cLine += str(aData[i][j])
                if j < nCols
                    cLine += ","
                ok
            next
            fwrite(oFile, cLine + nl)
        next
        
    func load(oFile)
        # قراءة الأبعاد
        cLine = trim(fgets(oFile))
        aDims = split(cLine, ",")
        nRows = number(aDims[1])
        nCols = number(aDims[2])
        
        # قراءة البيانات
        initializeZeros()
        for i = 1 to nRows
            cLine = trim(fgets(oFile))
            aValues = split(cLine, ",")
            for j = 1 to nCols
                aData[i][j] = number(aValues[j])
            next
        next
        
        return self
