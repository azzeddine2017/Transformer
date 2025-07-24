# globals.ring - ملف المتغيرات العامة للمشروع

# متغيرات التطبيق الرئيسية
app             # تطبيق Qt الرئيسي
oChat           # واجهة المحادثة
oTransformer    # نموذج المحول
oTokenizer      # معالج النصوص
oLogger         # نظام التسجيل
oConfig         # إعدادات النظام
oSession        # جلسة المحادثة

# مسارات الملفات
cModelPath = "models/transformer_model.bin"
cConfigPath = "config/config.json"
cLogPath = "logs/translator.log"

# إعدادات افتراضية
nMaxLength = 128          # أقصى طول للجملة
nContextSize = 5         # حجم سياق المحادثة
nBatchSize = 32         # حجم الدفعة للتدريب
nEmbeddingSize = 512    # حجم التضمين
nHeads = 8              # عدد رؤوس الانتباه

# قوائم عامة
aLanguages = ["ar", "en"]
aSpecialTokens = ["[START]", "[END]", "[PAD]", "[UNK]"]
