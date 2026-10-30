import 'package:flutter/material.dart';

// [snippet:form-controller]
class TextInputDemo extends StatefulWidget {
  const TextInputDemo({super.key});

  @override
  State<TextInputDemo> createState() => _TextInputDemoState();
}

class _TextInputDemoState extends State<TextInputDemo> {
  // 文字存在 controller 裡，TextField 直接讀寫它
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // controller 要自己釋放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: '輸入一些文字',
              border: OutlineInputBorder(),
            ),
          ),
          // controller 是 Listenable：只有這一行會隨輸入重建
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => Text('${_controller.text.length} 個字'),
          ),
          Row(
            spacing: 8,
            children: [
              OutlinedButton(
                // 從外部改文字：直接設定 controller.text
                onPressed: () => _controller.text = _controller.text.toUpperCase(),
                child: const Text('轉大寫'),
              ),
              OutlinedButton(
                onPressed: _controller.clear,
                child: const Text('清除'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// [/snippet]

// [snippet:form-validate]
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  // 用 GlobalKey 從外部拿到 FormState，呼叫 validate()
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  String? _result;

  @override
  void dispose() {
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      // 送出後出現錯誤的欄位，使用者一邊修改就一邊重新驗證
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: '名稱'),
            textInputAction: TextInputAction.next,
            // 鍵盤按「下一個」時把焦點移到 Email
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            validator: (v) => (v == null || v.trim().isEmpty) ? '請輸入名稱' : null,
            onSaved: (v) => _result = '名稱：$v',
          ),
          const SizedBox(height: 12),
          TextFormField(
            focusNode: _emailFocus,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (v) => (v != null && v.contains('@')) ? null : 'Email 格式不正確',
            onSaved: (v) => setState(() => _result = '$_result，Email：$v'),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(onPressed: _submit, child: const Text('送出')),
          ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            Text('已送出 → $_result'),
          ],
        ],
      ),
    );
  }
}
// [/snippet]
