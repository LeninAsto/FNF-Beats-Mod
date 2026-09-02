package beats;

class BeatsMenuConfig {
	public static var version:String = '1.0';
	public static var bg:String = 'BG';
	public static var bgFlash:String = 'BGdesat';
	public static var border:String = 'borde';
	public static var randomArtFolder:String = 'menu_waos';
	public static var menuAtlasFolder:String = 'menuPrincipal';
	public static var galleryFolder:String = 'cosas';
	public static var flashColor:Int = 0xff653bff;

	public static function randomArt():Array<String> {
		return ['angie', 'boyfriend', 'gato', 'mairl', 'rebeca', 'zaida'];
	}

	public static function galleryItems():Array<String> {
		return [
			'134 sin titulo',
			'4 sin titulo',
			'7 sin titulo3_0000-18-40',
			'8 sin titulo_0000-36-00',
			'L1',
			'L2',
			'L3',
			'L4',
			'L5',
			'L6',
			'L7',
			'L8',
			'lmfao',
			'lmfao2'
		];
	}

	public static function mainItems():Array<Dynamic> {
		return [
			{name: 'modo-historia', target: 'story', x: -90.0, y: -40.0},
			{name: 'juego-libre', target: 'freeplay', x: -100.0, y: 200.0},
			{name: 'opciones', target: 'options', x: -160.0, y: 400.0},
			{name: 'cosas', target: 'gallery', x: 1030.0, y: 10.0},
			{name: 'logros', target: 'achievements', x: 1000.0, y: 250.0},
			{name: 'creditos', target: 'credits', x: 920.0, y: 500.0}
		];
	}
}
