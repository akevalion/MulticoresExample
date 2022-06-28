Class {
	#name : #Benchs,
	#superclass : #Object,
	#category : #Multi
}

{ #category : #benchmarking }
Benchs >> benchRotatingSquares [

	| canvas shapes extent points frameCount border roassalMorph |

	canvas := RSCanvas new.
	canvas aaNone.
	canvas color: Color black.
	extent := 1920 @ 1080.
	
	points := (0 to: extent x by: 5) flatCollect: [ :x | 
		          (0 to: extent y by: 5) collect: [ :y | 
			          x @ y - (extent / 2) ] ].
	border := RSBorder new
		          color: (Color gray alpha: 0.5);
		          yourself.

	shapes := points collect: [ :p | 
		          RSBox new
			          extent: 140 @ 40;
			          model: p;
			          color: Color white;
			          border: border;
			          yourself ].
	canvas addAll: shapes.
	frameCount := 0.
	canvas newAnimation
		repeat;
		onStepDo: [ 
			shapes do: [ :s | 
					s matrix
						loadIdentity;
						translateBy: s model;
						rotateByRadians:
							(s model x + s model y + frameCount) degreesToRadians * 1.95 ].
			frameCount := frameCount + 1 ].
	canvas @ RSGraphCanvasMonitorInteraction.
	roassalMorph := canvas createMorph
		                extent: extent;
		                yourself.

	^ [ roassalMorph drawOnMockCanvas ] bench
]
