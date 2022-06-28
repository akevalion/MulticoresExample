Class {
	#name : #MultiExample,
	#superclass : #Object,
	#category : #Multi
}

{ #category : #running }
MultiExample >> run [
	<script: 'self new run'>
	| canvas extent size gap frame |
	canvas := RSCanvas new.
	extent := 32@ 16.
	size := 30.
	gap := 10.
	1 to: extent x do: [ :col |
		1 to: extent y do: [ :row | 
			| box |
			box := RSBox new.
			box model: col @ row.
			box position: (col @ row) * (size+gap).
			box size: size.
			canvas add: box ] ].
	canvas when: RSExtentChangedEvent do: [ :evt | 
		canvas camera zoomToFit: canvas extent - 10 rectangle: canvas encompassingRectangle.
		canvas signalUpdate ].
	frame := 0.
	canvas @ RSGraphCanvasMonitorInteraction.
	canvas newAnimation
		repeat;
		onStepDo: [ :t | 
			canvas nodes do: [ :shape | | point angle delta |
				point := shape model.
				angle := (point x + point y + frame) degreesToRadians * 3.
				shape cornerRadius: (angle+point y) cos abs * (size / 2).
				delta := angle cos @ angle sin.
				shape paint: (RSGradientPalette morpheusDen
					start: delta * size / 2;
					stop: delta * size / -2;
					yourself
					).
				shape matrix
					loadIdentity;
					translateBy: (point x @ point y) * (size+gap);
					rotateByRadians: angle. ].
			frame := frame + 1.
			
			].
	
	canvas open
		setLabel: 'Multi';
		position: 0@50;
		extent: 1920@1080
]
