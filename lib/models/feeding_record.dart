/// 喂奶记录数据模型
class FeedingRecord {
  final int? id;
  final DateTime startTime;
  final int? amountPrepared; // 冲了多少毫升
  final int? amountConsumed; // 吃了多少毫升
  final String? notes; // 备注

  FeedingRecord({
    this.id,
    required this.startTime,
    this.amountPrepared,
    this.amountConsumed,
    this.notes,
  });

  /// 从数据库Map创建FeedingRecord
  factory FeedingRecord.fromMap(Map<String, dynamic> map) {
    return FeedingRecord(
      id: map['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      amountPrepared: map['amount_prepared'],
      amountConsumed: map['amount_consumed'],
      notes: map['notes'],
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.millisecondsSinceEpoch,
      'amount_prepared': amountPrepared,
      'amount_consumed': amountConsumed,
      'notes': notes,
    };
  }

  /// 复制并修改某些字段
  FeedingRecord copyWith({
    int? id,
    DateTime? startTime,
    int? amountPrepared,
    int? amountConsumed,
    String? notes,
  }) {
    return FeedingRecord(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      amountPrepared: amountPrepared ?? this.amountPrepared,
      amountConsumed: amountConsumed ?? this.amountConsumed,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'FeedingRecord{id: $id, startTime: $startTime, amountPrepared: $amountPrepared, amountConsumed: $amountConsumed, notes: $notes}';
  }
}
