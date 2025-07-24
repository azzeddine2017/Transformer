Load "stdlibcore.ring"

# فئة معالجة النصوص العربية والإنجليزية
Class ArabicTokenizer
    # المكونات الأساسية
    aVocab = []         # قائمة المفردات
    aSpecialTokens = [] # الرموز الخاصة
    nMaxLen = 128       # أقصى طول للجملة
    
    func init
        # تهيئة الرموز الخاصة
        aSpecialTokens = [
            "[PAD]",   # للحشو
            "[UNK]",   # للكلمات غير المعروفة
            "[START]", # بداية الجملة
            "[END]"    # نهاية الجملة
        ]
        
        # تحميل المفردات
        loadVocabulary()
        return self
        
    func loadVocabulary
        try
            if isFile("data/vocab.txt")
                # قراءة المفردات من الملف
                oFile = fopen("data/vocab.txt", "r")
                while not feof(oFile)
                    cWord = trim(fgets(oFile))
                    if len(cWord) > 0
                        Add(aVocab, cWord)
                    ok
                end
                fclose(oFile)
            else
                # إنشاء مفردات افتراضية
                aVocab = aSpecialTokens
            ok
        catch
            See "تحذير: فشل تحميل المفردات" + nl
            aVocab = aSpecialTokens
        end
        
    func saveVocabulary
        try
            oFile = fopen("data/vocab.txt", "w")
            for word in aVocab
                fwrite(oFile, word + nl)
            next
            fclose(oFile)
        catch
            See "خطأ: فشل حفظ المفردات" + nl
        end
        
    func tokenize(cText, cLang="ar")
        # تنظيف النص
        cText = cleanText(cText, cLang)
        
        # تقسيم النص إلى كلمات
        aWords = split(cText)
        
        # تحويل الكلمات إلى رموز
        aTokens = []
        Add(aTokens, findToken("[START]"))
        
        for word in aWords
            if len(aTokens) >= nMaxLen-1
                exit
            ok
            
            nToken = findToken(word)
            Add(aTokens, nToken)
        next
        
        Add(aTokens, findToken("[END]"))
        
        # إضافة حشو إذا كان ضرورياً
        while len(aTokens) < nMaxLen
            Add(aTokens, findToken("[PAD]"))
        end
        
        return aTokens
        
    func detokenize(aTokens, cLang="en")
        aWords = []
        
        for token in aTokens
            if token >= 1 and token <= len(aVocab)
                cWord = aVocab[token]
                
                # تجاهل الرموز الخاصة
                if not isSpecialToken(cWord)
                    Add(aWords, cWord)
                ok
            ok
        next
        
        # دمج الكلمات
        cText = ""
        for i = 1 to len(aWords)
            cText += aWords[i]
            if i < len(aWords)
                cText += " "
            ok
        next
        
        return cText
        
    private
        func cleanText(cText, cLang)
            # إزالة علامات الترقيم والأرقام
            cText = replaceSpecialChars(cText)
            
            # تحويل إلى أحرف صغيرة للإنجليزية
            if cLang = "en"
                cText = lower(cText)
            ok
            
            # إزالة المسافات الزائدة
            cText = trim(cText)
            while substr(cText, "  ")
                cText = substr(cText, "  ", " ")
            end
            
            return cText
            
        func replaceSpecialChars(cText)
            # قائمة الرموز للاستبدال
            aChars = [
                ".", " ", ",", " ", ";", " ",
                "!", " ", "?", " ", '\"', " ",
                "'", " ", "(", " ", ")", " ",
                "[", " ", "]", " ", "{", " ",
                "}", " ", "-", " ", "_", " ",
                "0", " ", "1", " ", "2", " ",
                "3", " ", "4", " ", "5", " ",
                "6", " ", "7", " ", "8", " ",
                "9", " "
            ]
            
            # استبدال كل رمز
            for i = 1 to len(aChars) step 2
                while substr(cText, aChars[i])
                    cText = substr(cText, aChars[i], aChars[i+1])
                end
            next
            
            return cText
            
        func findToken(cWord)
            # البحث في المفردات
            for i = 1 to len(aVocab)
                if aVocab[i] = cWord
                    return i
                ok
            next
            
            # إضافة كلمة جديدة إذا كانت المفردات غير مكتملة
            if len(aVocab) < 32000 and not isSpecialToken(cWord)
                Add(aVocab, cWord)
                return len(aVocab)
            ok
            
            # إرجاع رمز الكلمة غير المعروفة
            return findToken("[UNK]")
            
        func isSpecialToken(cWord)
            for token in aSpecialTokens
                if token = cWord
                    return true
                ok
            next
            return false
