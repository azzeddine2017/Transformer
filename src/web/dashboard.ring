Load "weblib.ring"
import System.Web

Class Dashboard
    func getPage
        oPage = new HTMLPage {
            Title = "لوحة التحكم بالنموذج"
            
            html(`
                <style>
                    body {
                        font-family: 'Arial', sans-serif;
                        margin: 0;
                        padding: 20px;
                        background: #f5f5f5;
                        direction: rtl;
                    }
                    .container {
                        max-width: 1200px;
                        margin: 0 auto;
                        background: white;
                        padding: 20px;
                        border-radius: 8px;
                        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                    }
                    .header {
                        text-align: center;
                        margin-bottom: 30px;
                    }
                    .card {
                        background: #fff;
                        padding: 20px;
                        margin-bottom: 20px;
                        border-radius: 8px;
                        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
                    }
                    .btn {
                        background: #007bff;
                        color: white;
                        padding: 10px 20px;
                        border: none;
                        border-radius: 4px;
                        cursor: pointer;
                    }
                    .btn:hover {
                        background: #0056b3;
                    }
                    .form-group {
                        margin-bottom: 15px;
                    }
                    .form-group label {
                        display: block;
                        margin-bottom: 5px;
                    }
                    .form-control {
                        width: 100%;
                        padding: 8px;
                        border: 1px solid #ddd;
                        border-radius: 4px;
                    }
                </style>
                
                <div class="container">
                    <div class="header">
                        <h1>لوحة التحكم بالنموذج</h1>
                    </div>
                    
                    <div class="card">
                        <h2>تسجيل الدخول</h2>
                        <form id="loginForm">
                            <div class="form-group">
                                <label>اسم المستخدم:</label>
                                <input type="text" class="form-control" id="username">
                            </div>
                            <div class="form-group">
                                <label>كلمة المرور:</label>
                                <input type="password" class="form-control" id="password">
                            </div>
                            <button type="submit" class="btn">تسجيل الدخول</button>
                        </form>
                    </div>
                    
                    <div class="card" id="modelControls" style="display: none;">
                        <h2>التحكم بالنموذج</h2>
                        <div class="form-group">
                            <label>رفع البيانات:</label>
                            <input type="file" class="form-control" id="dataFile">
                            <button class="btn" onclick="uploadData()">رفع</button>
                        </div>
                        
                        <div class="form-group">
                            <label>تدريب النموذج:</label>
                            <input type="number" class="form-control" id="epochs" placeholder="عدد الدورات">
                            <button class="btn" onclick="trainModel()">تدريب</button>
                        </div>
                        
                        <div class="form-group">
                            <label>اختبار النموذج:</label>
                            <textarea class="form-control" id="testInput" placeholder="أدخل النص للاختبار"></textarea>
                            <button class="btn" onclick="testModel()">اختبار</button>
                        </div>
                        
                        <div id="result"></div>
                    </div>
                </div>
                
                <script>
                    let token = '';
                    
                    // تسجيل الدخول
                    document.getElementById('loginForm').onsubmit = async (e) => {
                        e.preventDefault();
                        const username = document.getElementById('username').value;
                        const password = document.getElementById('password').value;
                        
                        const response = await fetch('/auth/login', {
                            method: 'POST',
                            headers: {'Content-Type': 'application/json'},
                            body: JSON.stringify({username, password})
                        });
                        
                        const data = await response.json();
                        if (data.success) {
                            token = data.data.token;
                            document.getElementById('loginForm').parentElement.style.display = 'none';
                            document.getElementById('modelControls').style.display = 'block';
                        } else {
                            alert(data.message);
                        }
                    };
                    
                    // رفع البيانات
                    async function uploadData() {
                        const file = document.getElementById('dataFile').files[0];
                        if (!file) return alert('الرجاء اختيار ملف');
                        
                        const formData = new FormData();
                        formData.append('data', file);
                        
                        const response = await fetch('/data/upload', {
                            method: 'POST',
                            headers: {'Authorization': token},
                            body: formData
                        });
                        
                        const data = await response.json();
                        alert(data.message);
                    }
                    
                    // تدريب النموذج
                    async function trainModel() {
                        const epochs = document.getElementById('epochs').value;
                        
                        const response = await fetch('/model/train', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'Authorization': token
                            },
                            body: JSON.stringify({epochs})
                        });
                        
                        const data = await response.json();
                        alert(data.message);
                    }
                    
                    // اختبار النموذج
                    async function testModel() {
                        const input = document.getElementById('testInput').value;
                        
                        const response = await fetch('/model/predict', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'Authorization': token
                            },
                            body: JSON.stringify({input})
                        });
                        
                        const data = await response.json();
                        if (data.success) {
                            document.getElementById('result').innerHTML = 
                                '<div class="card"><h3>النتيجة:</h3><p>' + 
                                data.data.prediction + '</p></div>';
                        } else {
                            alert(data.message);
                        }
                    }
                </script>
            `)
        }
        return oPage
