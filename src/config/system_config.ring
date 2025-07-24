Load "stdlibcore.ring"
Load "json.ring"

Class SystemConfig
    # إعدادات النموذج
    cModelName = "transformer_ar"
    nModelVersion = "1.0"
    
    # أبعاد النموذج
    nDModel = 512
    nNumHeads = 8
    nNumLayers = 6
    nFFNDim = 2048
    nMaxSeqLength = 512
    
    # إعدادات التدريب
    nBatchSize = 32
    nEpochs = 100
    fLearningRate = 0.0001
    fDropout = 0.1
    
    # إعدادات النظام
    cCachePath = "cache/"
    cModelPath = "models/"
    cLogPath = "logs/"
    nLogLevel = 2  # 0: خطأ، 1: تحذير، 2: معلومات، 3: تصحيح
    
    # تهيئة الإعدادات
    func init
        if not DirExists(cCachePath) mkdir(cCachePath) ok
        if not DirExists(cModelPath) mkdir(cModelPath) ok
        if not DirExists(cLogPath) mkdir(cLogPath) ok
    
    # تحميل الإعدادات من ملف
    func loadFromFile(cPath)
        if exists(cPath)
            cContent = read(cPath)
            oJSON = new JSON
            aConfig = oJSON.decode(cContent)
            for key in aConfig
                if isAttribute(key[1])
                    setAttribute(self, key[1], key[2])
                ok
            next
            return true
        ok
        return false
    
    # حفظ الإعدادات إلى ملف
    func saveToFile(cPath)
        oJSON = new JSON
        cContent = oJSON.encode(getAttributes())
        write(cPath, cContent)
        return true
    
    private
        # التحقق من وجود الخاصية
        func isAttribute(cName)
            try
                eval("return type(" + cName + ") != 'UNDEFINED'")
            catch
                return false
            done
            return true
        
        # الحصول على جميع الخصائص
        func getAttributes
            aResult = []
            for cAttr in attributes(self)
                if cAttr[1] != "init" and cAttr[1] != "loadFromFile" and 
                   cAttr[1] != "saveToFile" and cAttr[1] != "isAttribute" and
                   cAttr[1] != "getAttributes"
                    add(aResult, [cAttr[1], getAttribute(self, cAttr[1])])
                ok
            next
            return aResult
