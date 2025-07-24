Load "httplib.ring"

# عميل واجهة برمجة التطبيقات
Class APIClient
    # المكونات الأساسية
    oClient
    cBaseURL
    cHost = "localhost"
    nPort = 8080
    func init(cHost, nPort)
        cBaseURL = "http://" + cHost + ":" + nPort
        oClient = new HTTPClient
    
    # دوال النموذج
    func trainModel(cDataPath, nEpochs = 0)
        return post("/model/train", [
            "data_path"= cDataPath,
            "epochs"= nEpochs
        ])
    
    func predict(cInput)
        return post("/model/predict", [
            "input"= cInput
        ])
    
    func saveModel(cPath = "")
        return post("/model/save", [
            "path"= cPath
        ])
    
    func loadModel(cPath = "")
        return post("/model/load", [
            "path"= cPath
        ])
    
    # دوال البيانات
    func uploadData(cData)
        return post("/data/upload", [
            "data"= cData
        ])
    
    func preprocessData(cPath)
        return post("/data/preprocess", [
            "path"= cPath
        ])
    
    # دوال التكوين
    func getConfig
        return get("/config/get")
    
    func updateConfig(oConfig)
        return post("/config/update", oConfig)
    
    # دالة الحالة
    func getStatus
        return get("/status")
    
    # دوال مساعدة
    private
        func get(cEndpoint)
            cURL = cBaseURL + cEndpoint
            cResponse = oClient.get(cURL)
            return json_decode(cResponse)
        
        func post(cEndpoint, oData)
            cURL = cBaseURL + cEndpoint
            cResponse = oClient.post(cURL, json_encode(oData))
            return json_decode(cResponse)
