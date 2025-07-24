Load "stdlibcore.ring"
Load "../utils/logger.ring"
Load "../config/system_config.ring"

# مدير البيانات المركزي
Class DataManager {
    # المكونات الأساسية
    oConfig
    oLogger
    oCache
    
    # بيانات النظام
    aTrainingData
    aValidationData
    aTestData
    
    func init(){
        # تهيئة المكونات
        oConfig = new SystemConfig
        oLogger = new Logger
        
        # تهيئة الذاكرة المؤقتة
        initCache()
    }
    # تحميل البيانات
    func loadData(cPath){
        oLogger.info("جاري تحميل البيانات من: " + cPath)
        try
            if isCached(cPath)
                return loadFromCache(cPath)
            ok
            
            aData = loadRawData(cPath)
            cacheData(cPath, aData)
            return aData
        catch
            oLogger.error("خطأ في تحميل البيانات: " + cPath)
            return []
        done
    }
    # معالجة البيانات
    func preprocessData(aData)
        oLogger.info("جاري معالجة البيانات...")
        # هنا نضيف منطق معالجة البيانات
        return aData
    
    # تقسيم البيانات
    func splitData(aData, nTrainRation, nValRatio){
        oLogger.info("جاري تقسيم البيانات...")
        nTotal = len(aData)
        nTrainSize = floor(nTotal * nTrainRatio)
        nValSize = floor(nTotal * nValRatio)
        
        aTrainingData = slice(aData, 1, nTrainSize)
        aValidationData = slice(aData, nTrainSize + 1, nTrainSize + nValSize)
        aTestData = slice(aData, nTrainSize + nValSize + 1)
        
        return [aTrainingData, aValidationData, aTestData]
    }
    private
        # إدارة الذاكرة المؤقتة
        func initCache(){
            if not DirectoryExists(oConfig.cCachePath)
                CreateDirectory(oConfig.cCachePath)
            ok
        }
        func isCached(cPath){       
            cCacheFile = getCacheFilePath(cPath)
            return exists(cCacheFile)
        }
        func loadFromCache(cPath){
            cCacheFile = getCacheFilePath(cPath)
            return read(cCacheFile)
        }
        func cacheData(cPath, aData){
            cCacheFile = getCacheFilePath(cPath)
            write(cCacheFile, aData)
        }
        func getCacheFilePath(cPath){
            return oConfig.cCachePath + md5(cPath) + ".cache"
        }
        # تحميل البيانات الخام
        func loadRawData(cPath){
            if not exists(cPath)
                throw("ملف البيانات غير موجود: " + cPath)
            ok
            
            return read(cPath)
        }
}

