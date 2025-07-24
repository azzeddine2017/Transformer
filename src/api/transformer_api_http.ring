Load "httplib.ring"
Load "../config/system_config.ring"
Load "../core/transformer.ring"
Load "../core/data_manager.ring"
Load "../utils/logger.ring"

# تشغيل الخادم
func main
    oAPI = new TransformerAPI
    oAPI.start()

# واجهة برمجة التطبيقات الموحدة للمحول باستخدام HTTPLib
Class TransformerAPI
    # المكونات الأساسية
    oConfig
    oTransformer
    oDataManager
    oLogger
    oServer
    
    func init
        # تهيئة المكونات
        oConfig = new SystemConfig
        oTransformer = new Transformer
        oDataManager = new DataManager
        oLogger = new Logger("logs/api.log")
        oServer = new Server
        
        # إعداد المسارات
        setupRoutes()
    
    func start
        oLogger.info("بدء تشغيل الخادم على المنفذ 8080")
        oServer.listen("0.0.0.0", 8080)
    
    # إعداد مسارات API
    func setupRoutes
        # مسارات النموذج
        oServer.route(:Post, "/model/train", :handleTraining)
        oServer.route(:Post, "/model/predict", :handlePrediction)
        oServer.route(:Post, "/model/save", :handleSaveModel)
        oServer.route(:Post, "/model/load", :handleLoadModel)
        
        # مسارات البيانات
        oServer.route(:Post, "/data/upload", :handleDataUpload)
        oServer.route(:Post, "/data/preprocess", :handleDataPreprocess)
        
        # مسارات التكوين
        oServer.route(:Get, "/config/get", :handleGetConfig)
        oServer.route(:Post, "/config/update", :handleUpdateConfig)
        
        # مسار الحالة
        oServer.route(:Get, "/status", :handleStatus)
    
    # معالجات الطلبات
    func handleTraining
        try
            oLogger.info("بدء التدريب")
            oParams = parseRequest()
            
            if not oParams["data_path"]
                return sendError("لم يتم تحديد مسار البيانات")
            ok
            
            aTrainingData = oDataManager.loadData(oParams["data_path"])
            if len(aTrainingData) = 0
                return sendError("فشل تحميل بيانات التدريب")
            ok
            
            nEpochs = oParams["epochs"] ? oConfig.nEpochs
            oTransformer.train(aTrainingData, nEpochs)
            
            return sendSuccess("اكتمل التدريب بنجاح")
        catch
            return sendError("فشل التدريب: " + cCatchError)
        done
    
    func handlePrediction
        try
            oLogger.info("بدء التنبؤ")
            oParams = parseRequest()
            
            if not oParams["input"]
                return sendError("لم يتم تحديد المدخلات")
            ok
            
            cResult = oTransformer.predict(oParams["input"])
            return sendSuccess("تم التنبؤ بنجاح", {"prediction": cResult})
        catch
            return sendError("فشل التنبؤ: " + cCatchError)
        done
    
    func handleSaveModel
        try
            oParams = parseRequest()
            cPath = oParams["path"] ? oConfig.cModelPath + "model.save"
            
            if oTransformer.saveModel(cPath)
                return sendSuccess("تم حفظ النموذج بنجاح")
            ok
            
            return sendError("فشل حفظ النموذج")
        catch
            return sendError("خطأ في حفظ النموذج: " + cCatchError)
        done
    
    func handleLoadModel
        try
            oParams = parseRequest()
            cPath = oParams["path"] ? oConfig.cModelPath + "model.save"
            
            if oTransformer.loadModel(cPath)
                return sendSuccess("تم تحميل النموذج بنجاح")
            ok
            
            return sendError("فشل تحميل النموذج")
        catch
            return sendError("خطأ في تحميل النموذج: " + cCatchError)
        done
    
    func handleDataUpload
        try
            oParams = parseRequest()
            if not oParams["data"]
                return sendError("لم يتم تحديد البيانات")
            ok
            
            cPath = oConfig.cCachePath + "upload_" + random(1000000) + ".data"
            write(cPath, oParams["data"])
            
            return sendSuccess("تم رفع البيانات بنجاح", {"path": cPath})
        catch
            return sendError("خطأ في رفع البيانات: " + cCatchError)
        done
    
    func handleDataPreprocess
        try
            oParams = parseRequest()
            if not oParams["path"]
                return sendError("لم يتم تحديد مسار البيانات")
            ok
            
            aData = oDataManager.loadData(oParams["path"])
            aProcessedData = oDataManager.preprocessData(aData)
            
            cOutputPath = oConfig.cCachePath + "processed_" + random(1000000) + ".data"
            write(cOutputPath, aProcessedData)
            
            return sendSuccess("تم معالجة البيانات بنجاح", {"path": cOutputPath})
        catch
            return sendError("خطأ في معالجة البيانات: " + cCatchError)
        done
    
    func handleGetConfig
        try
            return sendSuccess("تم جلب الإعدادات بنجاح", oConfig.getAttributes())
        catch
            return sendError("خطأ في جلب الإعدادات: " + cCatchError)
        done
    
    func handleUpdateConfig
        try
            oParams = parseRequest()
            for key in oParams
                if oConfig.isAttribute(key[1])
                    setAttribute(oConfig, key[1], key[2])
                ok
            next
            
            return sendSuccess("تم تحديث الإعدادات بنجاح")
        catch
            return sendError("خطأ في تحديث الإعدادات: " + cCatchError)
        done
    
    func handleStatus
        try
            oStatus = {
                "server": "running",
                "model_loaded": oTransformer != null,
                "config": oConfig.getAttributes(),
                "memory_usage": system("wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value")
            }
            return sendSuccess("تم جلب حالة النظام بنجاح", oStatus)
        catch
            return sendError("خطأ في جلب حالة النظام: " + cCatchError)
        done
    
    # دوال مساعدة
    private
        func parseRequest
            return oServer.getPostData()
        
        func sendSuccess(cMessage, oData = null)
            oResponse = {
                "success": true,
                "message": cMessage
            }
            
            if oData != null
                oResponse["data"] = oData
            ok
            
            oServer.setContent(json_encode(oResponse), "application/json")
        
        func sendError(cMessage)
            oResponse = {
                "success": false,
                "message": cMessage
            }
            
            oServer.setContent(json_encode(oResponse), "application/json")
        
        func random(nMax)
            return string(random(1, nMax))
