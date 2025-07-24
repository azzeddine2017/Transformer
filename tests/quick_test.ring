Load "stdlibcore.ring"
Load "../src/core/transformer.ring"
Load "../src/core/config.ring"
Load "../src/utils/tokenizer.ring"
Load "../src/utils/logger.ring"

# اختبار سريع للنظام
func main()
    oLogger = new Logger("quick_test")
    oLogger.info("بدء الاختبار السريع...")
    
    # اختبار 1: تهيئة المكونات
    oLogger.info("اختبار 1: تهيئة المكونات")
    oConfig = new TransformerConfig()
    oTransformer = new Transformer(oConfig)
    oTokenizer = new ArabicTokenizer()
    
    # اختبار 2: الترميز وفك الترميز
    oLogger.info("اختبار 2: الترميز وفك الترميز")
    cTestArabic = "مرحباً بالعالم"
    aTokens = oTokenizer.tokenize(cTestArabic, true)
    cDecoded = oTokenizer.detokenize(aTokens)
    See "النص الأصلي: " + cTestArabic + nl
    See "النص بعد الترميز وفك الترميز: " + cDecoded + nl
    
    # اختبار 3: ترجمة جملة بسيطة
    oLogger.info("اختبار 3: ترجمة جملة بسيطة")
    try
        aTranslated = oTransformer.translate(aTokens)
        cTranslation = oTokenizer.detokenize(aTranslated)
        See "الترجمة: " + cTranslation + nl
    catch
        oLogger.error("فشل في الترجمة: " + cCatchError)
    end
    
    oLogger.info("اكتمل الاختبار السريع!")
