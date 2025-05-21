
import 'package:flutter/material.dart';
import '../../models/test_model.dart';
import 'graphPainter.dart';


class Graph extends StatefulWidget {
  CtgTest test = CtgTest();
  final int gridPerMin ;

  //Interpretations2 interpretations;

  Graph({this.gridPerMin = 3});

  @override
  GraphState createState() {
    return GraphState();
  }
}

class GraphState extends State<Graph> {
int mOffset = 0;

  double mTouchStart = 0;
  GraphState();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
     /* onHorizontalDragStart: (DragStartDetails start) =>
          _onDragStart(context, start),
      onHorizontalDragUpdate: (DragUpdateDetails update) =>
          _onDragUpdate(context, update),*/
      child:  Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: CustomPaint(
                    painter: GraphPainter(widget.test,this.mOffset,widget.gridPerMin),
                  )
              )

    );
  }


/*_onDragStart(BuildContext context, DragStartDetails start) {
  print(start.globalPosition.toString());
  RenderBox getBox = context.findRenderObject();
  mTouchStart = getBox.globalToLocal(start.globalPosition).dx;
  //print(mTouchStart.dx.toString() + "|" + mTouchStart.dy.toString());
}

_onDragUpdate(BuildContext context, DragUpdateDetails update) {
  //print(update.globalPosition.toString());
  RenderBox getBox = context.findRenderObject();
  var local = getBox.globalToLocal(update.globalPosition);
  double newChange = (mTouchStart-local.dx);
  setState(() {
    this.mOffset =  trap(this.mOffset+(newChange/20).truncate());
  });
  print(this.mOffset.toString());
}*/

int trap(int pos) {
  if (pos < 0)
    return 0;
  else if (pos > widget.test.bpmEntries.length)
    pos = widget.test.bpmEntries.length;

  return pos;
}


}
