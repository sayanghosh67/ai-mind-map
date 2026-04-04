import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../../domain/models/mind_map_node.dart' as model;

class MindMapWidget extends StatefulWidget {
  final model.MindMapNode rootNode;

  const MindMapWidget({super.key, required this.rootNode});

  @override
  State<MindMapWidget> createState() => _MindMapWidgetState();
}

class _MindMapWidgetState extends State<MindMapWidget> {
  final Graph graph = Graph()..isTree = true;
  late BuchheimWalkerConfiguration builder;

  @override
  void initState() {
    super.initState();
    _buildGraph(widget.rootNode);
    builder = BuchheimWalkerConfiguration()
      ..siblingSeparation = (100)
      ..levelSeparation = (100)
      ..subtreeSeparation = (100)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  Node _buildGraph(model.MindMapNode nodeMap) {
    final root = Node.Id(nodeMap.id);
    _traverseAndAdd(nodeMap, root);
    return root;
  }

  void _traverseAndAdd(model.MindMapNode currentMapNode, Node parentGraphNode) {
    for (var child in currentMapNode.children) {
      final childGraphNode = Node.Id(child.id);
      graph.addEdge(parentGraphNode, childGraphNode);
      _traverseAndAdd(child, childGraphNode);
    }
  }

  model.MindMapNode? _findNodeById(model.MindMapNode current, String id) {
    if (current.id == id) return current;
    for (var child in current.children) {
      final found = _findNodeById(child, id);
      if (found != null) return found;
    }
    return null;
  }

  Widget _nodeWidget(Node node) {
    final nodeId = node.key!.value.toString();
    final modelNode = _findNodeById(widget.rootNode, nodeId);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        modelNode?.label ?? '',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 5.0,
      child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: GraphView(
          graph: graph,
          algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
          paint: Paint()
            ..color = Theme.of(context).colorScheme.outline
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
          builder: (Node node) {
            return _nodeWidget(node);
          },
        ),
      ),
    );
  }
}
