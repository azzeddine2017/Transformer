Load "stdlibcore.ring"
Load "transformer.ring"
Load "tokenizer.ring"
Load "evaluator_advanced.ring"
Load "data_processor.ring"
Load "config.ring"
Load "logger.ring"

Class TestSuite
    # المكونات الأساسية
    oLogger
    oConfig
    oProcessor
    oEvaluator
    
    func init
        oLogger = new Logger("test_suite")
        oConfig = new TransformerConfig()
        oProcessor = new DataProcessor()
        oEvaluator = new AdvancedEvaluator()
        
    func runAllTests
        oLogger.info("بدء تشغيل مجموعة الاختبارات...")
        
        # اختبار المكونات الأساسية
        testTokenizer()
        testDataProcessor()
        testTransformer()
        testEvaluator()
        
        oLogger.info("اكتملت جميع الاختبارات!")
        
    private
        func testTokenizer
            oLogger.info("اختبار المحلل اللغوي...")
            
            oTokenizer = new ArabicTokenizer()
            
            # اختبار الترميز
            cTestArabic = "مرحباً بكم في نظام الترجمة"
            aTokens = oTokenizer.tokenize(cTestArabic, true)
            
            assert(len(aTokens) > 0, "فشل ترميز النص العربي")
            
            # اختبار فك الترميز
            cDecoded = oTokenizer.detokenize(aTokens)
            assert(len(cDecoded) > 0, "فشل فك ترميز النص")
            
            oLogger.info("اكتمل اختبار المحلل اللغوي")
            
        func testDataProcessor
            oLogger.info("اختبار معالج البيانات...")
            
            # إنشاء ملفات اختبار مؤقتة
            writeTestFile("test_src.txt", [
                "مرحباً بالعالم",
                "كيف حالك؟",
                "يوم جميل"
            ])
            
            writeTestFile("test_tgt.txt", [
                "Hello world",
                "How are you?",
                "Beautiful day"
            ])
            
            # اختبار معالجة البيانات
            aData = oProcessor.processDataset("test_src.txt", "test_tgt.txt")
            assert(len(aData) > 0, "فشل معالجة البيانات")
            
            # اختبار تحسين البيانات
            aAugmented = oProcessor.augmentData(aData)
            assert(len(aAugmented) > len(aData), "فشل تحسين البيانات")
            
            # تنظيف الملفات المؤقتة
            remove("test_src.txt")
            remove("test_tgt.txt")
            
            oLogger.info("اكتمل اختبار معالج البيانات")
            
        func testTransformer
            oLogger.info("اختبار نموذج المحول...")
            
            oTransformer = new Transformer(oConfig)
            
            # اختبار التهيئة
            assert(oTransformer != null, "فشل تهيئة النموذج")
            
            # اختبار الترجمة
            aTestInput = [1, 2, 3, 4, 5]  # رموز اختبار
            aOutput = oTransformer.forward(aTestInput)
            
            assert(len(aOutput) > 0, "فشل الترجمة")
            
            oLogger.info("اكتمل اختبار نموذج المحول")
            
        func testEvaluator
            oLogger.info("اختبار نظام التقييم...")
            
            # إنشاء بيانات اختبار
            aTestData = [
                [["مرحبا"], ["hello"]],
                [["شكرا"], ["thank", "you"]],
                [["نعم"], ["yes"]]
            ]
            
            # اختبار التقييم
            oTransformer = new Transformer(oConfig)
            oReport = oEvaluator.evaluateModel(oTransformer, aTestData)
            
            assert(oReport != null, "فشل إنشاء تقرير التقييم")
            assert(oReport.bleu >= 0 and oReport.bleu <= 1, "درجة BLEU غير صالحة")
            assert(oReport.wer >= 0, "معدل خطأ الكلمات غير صالح")
            
            oLogger.info("اكتمل اختبار نظام التقييم")
            
        func writeTestFile(cFileName, aLines)
            fp = fopen(cFileName, "w")
            for line in aLines
                fputs(fp, line + nl)
            next
            fclose(fp)
            
        func assert(bCondition, cMessage)
            if not bCondition
                oLogger.error("فشل الاختبار: " + cMessage)
                raise(cMessage)
            ok
