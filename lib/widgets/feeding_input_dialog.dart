import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 喂奶信息输入对话框
class FeedingInputDialog extends StatefulWidget {
  final Function(int?, int?, String?) onConfirm;

  const FeedingInputDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<FeedingInputDialog> createState() => _FeedingInputDialogState();
}

class _FeedingInputDialogState extends State<FeedingInputDialog> {
  final _preparedController = TextEditingController();
  final _consumedController = TextEditingController();
  final _notesController = TextEditingController();
  bool _skipInput = false;

  @override
  void dispose() {
    _preparedController.dispose();
    _consumedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '记录小熊猫嗷嗷叫信息',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 跳过输入选项
            CheckboxListTile(
              title: const Text('跳过信息记录，直接开始倒计时'),
              value: _skipInput,
              onChanged: (value) {
                setState(() {
                  _skipInput = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            
            if (!_skipInput) ...[
              const SizedBox(height: 16),
              
              // 准备了多少
              TextField(
                controller: _preparedController,
                decoration: const InputDecoration(
                  labelText: '准备了多少竹子 (毫升)',
                  hintText: '例如：120',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_drink),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),

              const SizedBox(height: 16),

              // 小熊猫吃了多少
              TextField(
                controller: _consumedController,
                decoration: const InputDecoration(
                  labelText: '小熊猫吃了多少 (毫升)',
                  hintText: '例如：100',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 备注
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '备注 (可选)',
                  hintText: '例如：小熊猫很开心 🐼',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('开始倒计时'),
        ),
      ],
    );
  }

  void _onConfirm() {
    if (_skipInput) {
      widget.onConfirm(null, null, null);
    } else {
      final amountPrepared = _preparedController.text.isEmpty 
          ? null 
          : int.tryParse(_preparedController.text);
      final amountConsumed = _consumedController.text.isEmpty 
          ? null 
          : int.tryParse(_consumedController.text);
      final notes = _notesController.text.isEmpty 
          ? null 
          : _notesController.text;
      
      widget.onConfirm(amountPrepared, amountConsumed, notes);
    }
    Navigator.pop(context);
  }
}
