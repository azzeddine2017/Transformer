Load "stdlibcore.ring"
Load "matrix.ring"
Load "logger.ring"

Class AdvancedEvaluator
    # المكونات الأساسية
    oLogger
    nMaxNGram = 4  # أقصى طول للـ n-gram
    
    func init
        oLogger = new Logger("evaluator")
        
    func evaluateModel(oModel, aTestData)
        oLogger.info("بدء التقييم الشامل للنموذج...")
        
        # المقاييس
        fBleuScore = 0
        fWER = 0      # معدل خطأ الكلمات
        fTER = 0      # معدل خطأ الترجمة
        nCorrect = 0  # عدد الترجمات الصحيحة تماماً
        
        for i = 1 to len(aTestData)
            aSrc = aTestData[i][1]
            aRef = aTestData[i][2]
            
            # الحصول على الترجمة
            aHyp = oModel.translate(aSrc)
            
            # حساب المقاييس
            fBleuScore += calculateBLEU(aRef, aHyp)
            fWER += calculateWER(aRef, aHyp)
            fTER += calculateTER(aRef, aHyp)
            
            # التحقق من التطابق التام
            if isExactMatch(aRef, aHyp)
                nCorrect++
            ok
            
            # عرض التقدم
            if i % 100 = 0
                oLogger.info("تم تقييم " + i + " جملة")
            ok
        next
        
        # حساب المتوسطات
        nTotal = len(aTestData)
        fBleuScore = fBleuScore / nTotal
        fWER = fWER / nTotal
        fTER = fTER / nTotal
        fAccuracy = nCorrect / nTotal * 100
        
        # إنشاء تقرير التقييم
        return new EvaluationReport{
            bleu: fBleuScore,
            wer: fWER,
            ter: fTER,
            accuracy: fAccuracy,
            total_samples: nTotal,
            perfect_matches: nCorrect
        }
        
    private
        func calculateBLEU(aRef, aHyp)
            # حساب درجة BLEU
            fScore = 0
            
            # حساب تطابق n-grams
            for n = 1 to nMaxNGram
                fScore += calculateNGramPrecision(aRef, aHyp, n)
            next
            
            fScore = fScore / nMaxNGram
            
            # تطبيق عقوبة الطول
            fBP = calculateBrevityPenalty(len(aRef), len(aHyp))
            
            return fBP * exp(fScore)
            
        func calculateWER(aRef, aHyp)
            # حساب معدل خطأ الكلمات باستخدام مسافة Levenshtein
            nDist = levenshteinDistance(aRef, aHyp)
            return nDist / len(aRef)
            
        func calculateTER(aRef, aHyp)
            # حساب معدل خطأ الترجمة
            nEdits = calculateMinimumEdits(aRef, aHyp)
            return nEdits / len(aRef)
            
        func calculateNGramPrecision(aRef, aHyp, n)
            # حساب دقة n-gram
            aRefNGrams = getNGrams(aRef, n)
            aHypNGrams = getNGrams(aHyp, n)
            
            if len(aHypNGrams) = 0
                return 0
            ok
            
            nMatches = 0
            for gram in aHypNGrams
                if find(aRefNGrams, gram) > 0
                    nMatches++
                ok
            next
            
            return nMatches / len(aHypNGrams)
            
        func calculateBrevityPenalty(nRefLen, nHypLen)
            if nHypLen > nRefLen
                return 1
            ok
            
            return exp(1 - nRefLen/nHypLen)
            
        func getNGrams(aTokens, n)
            aNGrams = []
            
            if len(aTokens) < n
                return aNGrams
            ok
            
            for i = 1 to len(aTokens) - n + 1
                cGram = ""
                for j = 0 to n-1
                    cGram += aTokens[i+j] + " "
                next
                add(aNGrams, trim(cGram))
            next
            
            return aNGrams
            
        func levenshteinDistance(aStr1, aStr2)
            nLen1 = len(aStr1)
            nLen2 = len(aStr2)
            
            aMatrix = []
            for i = 0 to nLen1
                add(aMatrix, list(nLen2 + 1))
                aMatrix[i+1][1] = i
            next
            
            for j = 0 to nLen2
                aMatrix[1][j+1] = j
            next
            
            for i = 1 to nLen1
                for j = 1 to nLen2
                    if aStr1[i] = aStr2[j]
                        nCost = 0
                    else
                        nCost = 1
                    ok
                    
                    aMatrix[i+1][j+1] = min([
                        aMatrix[i][j+1] + 1,    # حذف
                        aMatrix[i+1][j] + 1,    # إضافة
                        aMatrix[i][j] + nCost   # استبدال
                    ])
                next
            next
            
            return aMatrix[nLen1+1][nLen2+1]
            
        func calculateMinimumEdits(aRef, aHyp)
            # حساب الحد الأدنى من التعديلات المطلوبة للتحويل
            nShifts = 0
            nOtherEdits = levenshteinDistance(aRef, aHyp)
            
            # إضافة تكلفة النقل
            aAlignment = findBestAlignment(aRef, aHyp)
            nShifts = countShifts(aAlignment)
            
            return nOtherEdits + nShifts
            
        func findBestAlignment(aRef, aHyp)
            # تنفيذ مبسط للمحاذاة
            aAlignment = []
            nRefPos = 1
            
            for token in aHyp
                nPos = find(aRef, token)
                if nPos > 0
                    add(aAlignment, nPos)
                    nRefPos = nPos + 1
                else
                    add(aAlignment, 0)
                ok
            next
            
            return aAlignment
            
        func countShifts(aAlignment)
            nShifts = 0
            nPrev = 0
            
            for pos in aAlignment
                if pos != 0
                    if pos < nPrev
                        nShifts++
                    ok
                    nPrev = pos
                ok
            next
            
            return nShifts
            
        func isExactMatch(aRef, aHyp)
            if len(aRef) != len(aHyp)
                return false
            ok
            
            for i = 1 to len(aRef)
                if aRef[i] != aHyp[i]
                    return false
                ok
            next
            
            return true
            
        func min(aList)
            if len(aList) = 0
                return 0
            ok
            
            nMin = aList[1]
            for n in aList
                if n < nMin
                    nMin = n
                ok
            next
            
            return nMin

Class EvaluationReport
    # مقاييس التقييم
    bleu = 0.0        # درجة BLEU
    wer = 0.0         # معدل خطأ الكلمات
    ter = 0.0         # معدل خطأ الترجمة
    accuracy = 0.0    # دقة الترجمة
    total_samples = 0 # عدد العينات الكلي
    perfect_matches = 0 # عدد التطابقات التامة
    
    func toString
        return "تقرير التقييم:" + nl +
               "درجة BLEU: " + bleu + nl +
               "معدل خطأ الكلمات: " + wer + nl +
               "معدل خطأ الترجمة: " + ter + nl +
               "الدقة: " + accuracy + "%" + nl +
               "عدد العينات: " + total_samples + nl +
               "التطابقات التامة: " + perfect_matches
