# إعدادات النموذج
Class TransformerConfig
    # أبعاد النموذج
    nDModel = 512          # أبعاد النموذج
    nNumLayers = 6         # عدد طبقات المشفر وفك التشفير
    nNumHeads = 8          # عدد رؤوس الانتباه
    nDFF = 2048           # أبعاد طبقة التغذية الأمامية
    
    # حجم المفردات
    nSrcVocabSize = 32000  # حجم مفردات اللغة المصدر (العربية)
    nTgtVocabSize = 32000  # حجم مفردات اللغة الهدف (الإنجليزية)
    
    # معلمات التدريب
    nBatchSize = 32        # حجم الدفعة
    nEpochs = 100         # عدد الدورات
    fLearningRate = 0.001 # معدل التعلم
    fDropout = 0.1        # معدل الإسقاط
    
    # مسارات الملفات
    cTrainSrc = "data/train.ar"    # ملف تدريب اللغة المصدر
    cTrainTgt = "data/train.en"    # ملف تدريب اللغة الهدف
    cValidSrc = "data/valid.ar"    # ملف تحقق اللغة المصدر
    cValidTgt = "data/valid.en"    # ملف تحقق اللغة الهدف
    cTestSrc = "data/test.ar"      # ملف اختبار اللغة المصدر
    cTestTgt = "data/test.en"      # ملف اختبار اللغة الهدف
    
    # مسارات حفظ النموذج
    cModelDir = "models/"          # مجلد حفظ النموذج
    cVocabDir = "vocab/"          # مجلد حفظ المفردات
    cLogDir = "logs/"             # مجلد حفظ السجلات
    
    # إعدادات متقدمة
    nMaxSeqLength = 128   # أقصى طول للجملة
    nWarmupSteps = 4000   # عدد خطوات التسخين
    fBeta1 = 0.9         # معامل الزخم لمحسن Adam
    fBeta2 = 0.98        # معامل التسارع لمحسن Adam
    fEpsilon = 1e-9      # معامل الاستقرار لمحسن Adam
    
    func init
        # إنشاء المجلدات إذا لم تكن موجودة
        if not isDirectory(cModelDir) createDir(cModelDir) ok
        if not isDirectory(cVocabDir) createDir(cVocabDir) ok
        if not isDirectory(cLogDir) createDir(cLogDir) ok
