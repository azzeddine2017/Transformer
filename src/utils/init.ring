Load "stdlibcore.ring"
Load "globals.ring"

# تهيئة المتغيرات العامة
func initGlobals
    # تهيئة نظام التسجيل
    oLogger = new Logger("system")
    oLogger.info("بدء تهيئة النظام...")
    
    # تهيئة الإعدادات
    oConfig = new TransformerConfig()
    
    # تهيئة المعالجات
    oTokenizer = new ArabicTokenizer()
    
    # تهيئة النموذج
    try
        oTransformer = new Transformer(oConfig)
        if isFile(cModelPath)
            oTransformer.loadModel(cModelPath)
            oLogger.info("تم تحميل النموذج بنجاح")
        else
            oLogger.warning("ملف النموذج غير موجود: " + cModelPath)
        ok
    catch
        oLogger.error("فشل في تهيئة النموذج: " + cCatchError)
    end
    
    oLogger.info("اكتملت تهيئة النظام")
    return true

# تنظيف المتغيرات العامة
func cleanupGlobals()
    if oLogger != NULL
        oLogger.info("تنظيف النظام...")
    ok
    
    # إغلاق الملفات والموارد
    if app != NULL
        app.quit()
    ok
    
    # تصفير المتغيرات
    app = NULL
    oChat = NULL
    oTransformer = NULL
    oTokenizer = NULL
    oLogger = NULL
    oConfig = NULL
    oSession = NULL
