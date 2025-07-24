Load "stdlibcore.ring"
Load "tokenizer.ring"
Load "logger.ring"

Class DataProcessor
    # المكونات الرئيسية
    oTokenizer
    oLogger
    nMaxLength
    
    func init(nMaxLen)
        oTokenizer = new ArabicTokenizer()
        oLogger = new Logger("data_processor")
        nMaxLength = nMaxLen
        
    func processDataset(cSrcFile, cTgtFile)
        oLogger.info("معالجة البيانات من: " + cSrcFile + " و " + cTgtFile)
        
        # قراءة الملفات
        aSrcLines = readLines(cSrcFile)
        aTgtLines = readLines(cTgtFile)
        
        if len(aSrcLines) != len(aTgtLines)
            oLogger.error("عدد الأسطر غير متطابق في ملفي المصدر والهدف")
            return null
        ok
        
        # معالجة كل سطر
        aProcessedData = []
        for i = 1 to len(aSrcLines)
            # تنظيف وترميز النصوص
            aSrcTokens = processLine(aSrcLines[i], true)
            aTgtTokens = processLine(aTgtLines[i], false)
            
            if aSrcTokens != null and aTgtTokens != null
                add(aProcessedData, [aSrcTokens, aTgtTokens])
            ok
            
            # عرض التقدم
            if i % 1000 = 0
                oLogger.info("تمت معالجة " + i + " سطر")
            ok
        next
        
        oLogger.info("اكتملت المعالجة. تم معالجة " + len(aProcessedData) + " زوج من الجمل")
        return aProcessedData
        
    func processLine(cLine, bIsArabic)
        # تنظيف النص
        cLine = trim(cLine)
        if len(cLine) = 0 return null ok
        
        # ترميز النص
        aTokens = oTokenizer.tokenize(cLine, bIsArabic)
        
        # التحقق من الطول
        if len(aTokens) > nMaxLength
            return null
        ok
        
        return aTokens
        
    func augmentData(aData)
        oLogger.info("بدء تحسين البيانات...")
        aAugmented = []
        
        for aPair in aData
            # إضافة الزوج الأصلي
            add(aAugmented, aPair)
            
            # إضافة نسخة معكوسة للجملة العربية
            if len(aPair[1]) > 1
                aReversed = reverse(aPair[1])
                add(aAugmented, [aReversed, aPair[2]])
            ok
            
            # إضافة نسخة مع حذف عشوائي
            if len(aPair[1]) > 3
                aDropped = randomDrop(aPair[1])
                add(aAugmented, [aDropped, aPair[2]])
            ok
        next
        
        oLogger.info("اكتمل تحسين البيانات. حجم البيانات الجديد: " + len(aAugmented))
        return aAugmented
        
    private
        func readLines(cFile)
            if not isFile(cFile)
                oLogger.error("الملف غير موجود: " + cFile)
                return []
            ok
            
            try
                fp = fopen(cFile, "r")
                aLines = []
                
                while not feof(fp)
                    cLine = trim(fgets(fp))
                    if len(cLine) > 0
                        add(aLines, cLine)
                    ok
                end
                
                fclose(fp)
                return aLines
                
            catch
                oLogger.error("خطأ في قراءة الملف: " + cCatchError)
                return []
            end
            
        func reverse(aTokens)
            aResult = []
            for i = len(aTokens) to 1 step -1
                add(aResult, aTokens[i])
            next
            return aResult
            
        func randomDrop(aTokens)
            aResult = []
            for token in aTokens
                if random(100) > 20  # 20% احتمال الحذف
                    add(aResult, token)
                ok
            next
            return aResult
