Load "stdlibcore.ring"
Load "../core/transformer.ring"
Load "../core/config.ring"
Load "../utils/tokenizer.ring"
Load "../utils/logger.ring"
Load "../utils/globals.ring"
Load "../utils/init.ring"



# البرنامج الرئيسي
func main
    # تهيئة النظام
    if not initGlobals()
        See "فشل في تهيئة النظام" + nl
        return
    ok
    
    # تشغيل واجهة سطر الأوامر
    oCLI = new TranslatorCLI()
    
    # تحليل وسائط سطر الأوامر
    aArgs = sysargv
    
    if len(aArgs) = 1
        # الوضع التفاعلي
        oCLI.startInteractive()
    elseif len(aArgs) = 3
        # وضع معالجة الملفات
        oCLI.batchTranslate(aArgs[2], aArgs[3])
    else
        showUsage()
    ok
    
    # تنظيف النظام
    cleanupGlobals()

# واجهة سطر الأوامر للترجمة
Class TranslatorCLI
    # المكونات الأساسية
    oTransformer
    oTokenizer
    oLogger
    
    func init
        oLogger = new Logger("cli")
        oLogger.info("تهيئة نظام الترجمة...")
        
        # تحميل النموذج والمكونات
        oConfig = new TransformerConfig()
        oTransformer = new Transformer(oConfig)
        oTokenizer = new ArabicTokenizer()
        
        if loadModel()
            oLogger.info("تم تحميل النموذج بنجاح!")
        else
            oLogger.error("فشل تحميل النموذج!")
            return
        ok
        
    func loadModel
        try
            oTransformer.loadModel("models/transformer_model.bin")
            return true
        catch
            return false
        end
        
    func startInteractive
        See "مرحباً بك في نظام الترجمة العربية-الإنجليزية!" + nl
        See "اكتب 'خروج' للخروج من البرنامج" + nl + nl
        
        while true
            See "أدخل النص للترجمة: "
            cInput = GetString()
            
            if lower(cInput) = "خروج" or lower(cInput) = "exit"
                See "شكراً لاستخدام نظام الترجمة!" + nl
                exit
            ok
            
            if len(cInput) > 0
                translate(cInput)
            ok
        end
        
    func translate(cInput)
        try
            # معالجة النص المدخل
            aTokens = oTokenizer.tokenize(cInput, true)
            if len(aTokens) = 0
                See "خطأ: النص فارغ بعد المعالجة" + nl
                return
            ok
            
            # الترجمة
            See "جاري الترجمة..." + nl
            aOutput = oTransformer.translate(aTokens)
            
            # تحويل الرموز إلى نص
            cTranslation = oTokenizer.detokenize(aOutput)
            
            # عرض النتيجة
            See "الترجمة: " + cTranslation + nl + nl
            
        catch
            See "حدث خطأ أثناء الترجمة: " + cCatchError + nl
        end
        
    func batchTranslate(cInputFile, cOutputFile)
        if not isFile(cInputFile)
            See "خطأ: ملف المدخلات غير موجود" + nl
            return
        ok
        
        try
            # قراءة الملف
            fp = fopen(cInputFile, "r")
            fpOut = fopen(cOutputFile, "w")
            nCount = 0
            
            while not feof(fp)
                cLine = trim(fgets(fp))
                if len(cLine) > 0
                    # ترجمة السطر
                    aTokens = oTokenizer.tokenize(cLine, true)
                    aOutput = oTransformer.translate(aTokens)
                    cTranslation = oTokenizer.detokenize(aOutput)
                    
                    # كتابة الترجمة
                    fputs(fpOut, cTranslation + nl)
                    nCount++
                    
                    # عرض التقدم
                    if nCount % 10 = 0
                        See "تمت ترجمة " + nCount + " سطر..." + nl
                    ok
                ok
            end
            
            fclose(fp)
            fclose(fpOut)
            See "اكتملت الترجمة! تمت معالجة " + nCount + " سطر" + nl
            
        catch
            See "حدث خطأ أثناء معالجة الملف: " + cCatchError + nl
        end