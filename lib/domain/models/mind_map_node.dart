class MindMapNode {
  final String id;
  final String label;
  final List<MindMapNode> children;

  MindMapNode({
    required this.id,
    required this.label,
    this.children = const [],
  });

  factory MindMapNode.fromJson(Map<String, dynamic> json) {
    return MindMapNode(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: json['label'] ?? '',
      children: json['children'] != null
          ? (json['children'] as List).map((i) => MindMapNode.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}
