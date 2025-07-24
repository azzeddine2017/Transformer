Load "../src/api/api_client.ring"

# مثال على استخدام واجهة برمجة التطبيقات
func main()
    # إنشاء عميل API
    oClient = new APIClient
    
    # تحميل الإعدادات
    ? "جاري تحميل الإعدادات..."
    oConfig = oClient.getConfig()
    ? "الإعدادات الحالية:"
    ? oConfig
    
    # تحديث الإعدادات
    ? "جاري تحديث الإعدادات..."
    oClient.updateConfig([
        "nBatchSize"= 64,
        "nEpochs"= 50
    ])
    
    # رفع البيانات
    ? "جاري رفع البيانات..."
    cData = read("data/training_data.txt")
    oResponse = oClient.uploadData(cData)
    if not oResponse["success"]
        ? "خطأ في رفع البيانات: " + oResponse["message"]
        return
    ok
    
    cDataPath = oResponse["data"]["path"]
    ? "تم رفع البيانات إلى: " + cDataPath
    
    # معالجة البيانات
    ? "جاري معالجة البيانات..."
    oResponse = oClient.preprocessData(cDataPath)
    if not oResponse["success"]
        ? "خطأ في معالجة البيانات: " + oResponse["message"]
        return
    ok
    
    cProcessedPath = oResponse["data"]["path"]
    ? "تم معالجة البيانات في: " + cProcessedPath
    
    # تدريب النموذج
    ? "جاري تدريب النموذج..."
    oResponse = oClient.trainModel(cProcessedPath, 50)
    if not oResponse["success"]
        ? "خطأ في تدريب النموذج: " + oResponse["message"]
        return
    ok
    
    ? "تم تدريب النموذج بنجاح!"
    
    # حفظ النموذج
    ? "جاري حفظ النموذج..."
    oResponse = oClient.saveModel()
    if not oResponse["success"]
        ? "خطأ في حفظ النموذج: " + oResponse["message"]
        return
    ok
    
    ? "تم حفظ النموذج بنجاح!"
    
    # اختبار النموذج
    ? "جاري اختبار النموذج..."
    cInput = "مرحباً، كيف حالك؟"
    oResponse = oClient.predict(cInput)
    if not oResponse["success"]
        ? "خطأ في التنبؤ: " + oResponse["message"]
        return
    ok
    
    ? "المدخل: " + cInput
    ? "التنبؤ: " + oResponse["data"]["prediction"]
