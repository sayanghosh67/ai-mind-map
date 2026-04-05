import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../../domain/models/mind_map_node.dart' as model;

class MindMapWidget extends StatefulWidget {
  final model.MindMapNode rootNode;

  const MindMapWidget({super.key, required this.rootNode});

  @override
  State<MindMapWidget> createState() => MindMapWidgetState();
}

class MindMapWidgetState extends State<MindMapWidget> {
  late Graph graph;
  late BuchheimWalkerConfiguration builder;
  Map<String, bool> nodeExpandedState = {};

  @override
  void initState() {
    super.initState();
    builder = BuchheimWalkerConfiguration()
      ..siblingSeparation = (50)
      ..levelSeparation = (100)
      ..subtreeSeparation = (50)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);
    
    // Initialize root as expanded, others as well unless determined otherwise.
    _initializeExpandedState(widget.rootNode);
    _rebuildGraph();
  }

  void _initializeExpandedState(model.MindMapNode node) {
    nodeExpandedState[node.id] = true; 
    for (var child in node.children) {
      _initializeExpandedState(child);
    }
  }

  void _rebuildGraph() {
    graph = Graph()..isTree = true;
    final root = Node.Id(widget.rootNode.id);
    _traverseAndAdd(widget.rootNode, root);
  }

  void _traverseAndAdd(model.MindMapNode currentMapNode, Node parentGraphNode) {
    if (nodeExpandedState[currentMapNode.id] == true) {
      for (var child in currentMapNode.children) {
        final childGraphNode = Node.Id(child.id);
        graph.addEdge(parentGraphNode, childGraphNode);
        _traverseAndAdd(child, childGraphNode);
      }
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
    if (modelNode == null) return const SizedBox.shrink();

    final isExpanded = nodeExpandedState[nodeId] ?? true;
    final hasChildren = modelNode.children.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (hasChildren) {
          setState(() {
            nodeExpandedState[nodeId] = !isExpanded;
            _rebuildGraph();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasChildren 
              ? [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]
              : [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: hasChildren ? null : Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              modelNode.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: hasChildren ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasChildren) ...[
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: isExpanded ? 0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.1,
        maxScale: 3.0,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(40),
          child: GraphView(
            graph: graph,
            algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
            paint: Paint()
              ..color = Theme.of(context).colorScheme.primary.withOpacity(0.5)
              ..strokeWidth = 2.5
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              return _nodeWidget(node);
            },
          ),
        ),
      ),
    );
  }
}
