Class {
	#name : #MultiExample,
	#superclass : #Object,
	#instVars : [
		'size',
		'gap',
		'frame',
		'mainCanvas'
	],
	#category : #Multi
}

{ #category : #running }
MultiExample >> connectAsClient: position [
	'demo.txt' asFileReference writeStreamDo: [ :stream | position printOn: stream ].
	Smalltalk quitPrimitive.
]

{ #category : #running }
MultiExample >> createBox: point [
	| box |
	box := RSBox new.
	box model: point.
	box position: point * (size+gap).
	box size: size.
	^ box
]

{ #category : #running }
MultiExample >> handleRequest: request [
	
]

{ #category : #running }
MultiExample >> launchClient: position [
	OSSUnixSubprocess new
		command: Smalltalk vm fileName;
		arguments: { '--headless'. 'multicores.image'. 'eval'. '--save'. 
			'MultiExample new connectAsClient: ', position asString };
		workingDirectory: '.' asFileReference;
		addAllEnvVariablesFromParentWithoutOverride;
		redirectStdout;
		redirectStderr;
		terminateOnShutdown;
		run
		"runAndWaitOnExitDo: [ :process :outString :errString |
			process isSuccess traceCr.
			]"
		
]

{ #category : #running }
MultiExample >> run [
	<script: 'self new run open
		setLabel: ''Multi'';
		position: 0@50;
		extent: 1920@1080'>
	| canvas extent boxes |
	canvas := RSCanvas new.
	extent := 32@ 16.
	size := 30.
	gap := 10.
	boxes := (1 to: extent x) flatCollect: [ :col |
		(1 to: extent y) collect: [ :row | self createBox: col@row ] ].
	canvas addAll: boxes.
	
	canvas when: RSExtentChangedEvent do: [ :evt | 
		canvas camera zoomToFit: canvas extent - 10 rectangle: canvas encompassingRectangle.
		canvas signalUpdate ].
	frame := 0.
	canvas @ RSGraphCanvasMonitorInteraction.
	canvas newAnimation
		repeat;
		onStepDo: [ self updateBoxes: boxes ].
	^ canvas
]

{ #category : #running }
MultiExample >> runParallel [
	<script: 'self new runParallel open
		extent: 1920@1080;
		position: 0@50'>
	| boxes |
	mainCanvas := self run.
	boxes := mainCanvas shapes.
	self startServer.
	self startClients: 1.
	boxes do: #remove.
	^ mainCanvas
]

{ #category : #running }
MultiExample >> startClients: numberOfClients [
	1 to: numberOfClients do: [ :index | 
		self launchClient: index @ numberOfClients ].
]

{ #category : #running }
MultiExample >> startServer [
	(ZnServer startDefaultOn: 1701)
		delegate: self.
]

{ #category : #running }
MultiExample >> updateBoxes: boxes [
	boxes do: [ :shape | | point angle delta |
		point := shape model.
		angle := (point x + point y + frame) degreesToRadians * 3.
		shape cornerRadius: (angle+point y) cos abs * (size / 2).
		delta := angle cos @ angle sin.
		shape paint: (RSGradientPalette morpheusDen
			start: delta * size / 2;
			stop: delta * size / -2;
			yourself).
		shape matrix
			loadIdentity;
			translateBy: (point x @ point y) * (size+gap);
			rotateByRadians: angle. ].
	frame := frame + 1
]
