Load "stdlibcore.ring"
Load "math.ring"
Load "matrix.ring"
Load "fastpro.ring"

Class AdamOptimizer {
    # معلمات Adam
    fLearningRate = 0.001  # معدل التعلم
    fBeta1 = 0.9          # معامل الزخم
    fBeta2 = 0.999        # معامل التسارع
    fEpsilon = 1e-8       # معامل الاستقرار
    
    # متغيرات الحالة
    nStep = 0             # عداد الخطوات
    aM = []              # المتوسط المتحرك للتدرج
    aV = []              # المتوسط المتحرك لمربع التدرج
    
    func init(fLR){
        fLearningRate = fLR
        aM = []
        aV = []
    }    
    func step(aGradients){
        nStep++
        
        # تهيئة المتوسطات المتحركة إذا كانت فارغة
        if len(aM) = 0
            for grad in aGradients
                add(aM, matrix_zeros(len(grad), len(grad[1])))
                add(aV, matrix_zeros(len(grad), len(grad[1])))
            next
        ok
      
        # تحديث المتوسطات المتحركة
        for i = 1 to len(aGradients)
            # تحديث m
            aM[i] = matrix_scale(aM[i], fBeta1)
            aM[i] = matrix_add(aM[i], matrix_scale(aGradients[i], 1 - fBeta1))
            
            # تحديث v
            aV[i] = matrix_scale(aV[i], fBeta2)
            aV[i] = matrix_add(aV[i], matrix_scale(matrix_square(aGradients[i]), 1 - fBeta2))
            
            # تصحيح التحيز
            aMHat = matrix_scale(aM[i], 1 / (1 - pow(fBeta1, nStep)))
            aVHat = matrix_scale(aV[i], 1 / (1 - pow(fBeta2, nStep)))
            
            # تحديث المعلمات
            aDelta = matrix_divide(aMHat, matrix_add(matrix_sqrt(aVHat), fEpsilon))
            aDelta = matrix_scale(aDelta, fLearningRate)
            
            # إرجاع التحديثات
            aGradients[i] = aDelta
        next
        
        return aGradients
    }    
    private

    func matrix_zeros(nRows, nCols){
        # Use FastPro to create zero matrix
        aResult = matrix(nRows, nCols)
        return updateList(aResult, :fill, :matrix, 0)
    }

    func matrix_scale(aMatrix, scalar){
        # Use FastPro for scalar multiplication
        return updateList(aMatrix, :scalar, :matrix, scalar)
    }

    func matrix_add(aA, aB){
        # Use FastPro for matrix addition
        return updateList(aA, :add, :matrix, aB)
    }
    func matrix_square(aMatrix){
        # Use FastPro for element-wise square
        return updateList(aMatrix, :square, :matrix)
    }
    func matrix_sqrt(aMatrix){
        # Use FastPro for element-wise square root
        return updateList(aMatrix, :sqrt, :matrix)
    }
    func matrix_divide(aA, aB){
        if len(aA) != len(aB) or len(aA[1]) != len(aB[1])
            raise("أبعاد المصفوفات غير متوافقة للقسمة")
        ok
        
        aResult = matrix(len(aA), len(aA[1]))
        for i = 1 to len(aA)
            for j = 1 to len(aA[1])
                if aB[i][j] != 0
                    aResult[i][j] = aA[i][j] / aB[i][j]
                else
                    aResult[i][j] = 0
                ok
            next
        next
        return aResult
    }
}