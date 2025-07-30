import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 喂奶信息输入对话框
class FeedingInputDialog extends StatefulWidget {
  final Function(int?, int?, String?, Duration?) onConfirm;
  final Duration defaultDuration;

  const FeedingInputDialog({
    super.key,
    required this.onConfirm,
    required this.defaultDuration,
  });

  @override
  State<FeedingInputDialog> createState() => _FeedingInputDialogState();
}

class _FeedingInputDialogState extends State<FeedingInputDialog> {
  final _consumedController = TextEditingController();
  final _notesController = TextEditingController();
  bool _skipInput = false;
  late Duration _selectedDuration;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.defaultDuration;
  }

  @override
  void dispose() {
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
              
              // 倒计时时长选择
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('倒计时时长'),
                  subtitle: Text('${(_selectedDuration.inMinutes / 60).toStringAsFixed(1)} 小时'),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _showDurationPicker,
                ),
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
      widget.onConfirm(null, null, null, null);
    } else {
      final amountConsumed = _consumedController.text.isEmpty 
          ? null 
          : int.tryParse(_consumedController.text);
      final notes = _notesController.text.isEmpty 
          ? null 
          : _notesController.text;
      final customDuration = _selectedDuration != widget.defaultDuration 
          ? _selectedDuration 
          : null;
      
      widget.onConfirm(null, amountConsumed, notes, customDuration);
    }
    Navigator.pop(context);
  }

  /// 显示时长选择器
  void _showDurationPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择倒计时时长'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDurationOption(const Duration(hours: 2)),
            _buildDurationOption(const Duration(minutes: 150)), // 2.5小时
            _buildDurationOption(const Duration(hours: 3)),
            _buildDurationOption(const Duration(minutes: 210)), // 3.5小时
            _buildDurationOption(const Duration(hours: 4)),
            _buildDurationOption(const Duration(hours: 5)),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(Duration duration) {
    final hours = duration.inMinutes / 60;
    final title = hours == hours.toInt() 
        ? '${hours.toInt()} 小时'
        : '${hours.toStringAsFixed(1)} 小时';
    
    return ListTile(
      title: Text(title),
      onTap: () {
        setState(() {
          _selectedDuration = duration;
        });
        Navigator.pop(context);
      },
    );
  }
}
