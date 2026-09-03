extends Node2D



# 场景


const FRUIT_SCENE := preload("res://fruit/fruit.tscn")

var a = 1.5
# 水果数据


const FRUIT_DATA := [
	{
		"name": "洛茜",
		"radius": 30.0,
		"size": 0.16,
		"score": 1
	},
	{
		"name": "汤汤",
		"radius": 39.0,
		"size": 0.09,
		"score": 3
	},
	{
		"name": "陈千语",
		"radius": 48.0,
		"size": 0.11,
		"score": 6
	},
	{
		"name": "别礼",
		"radius": 55.0,
		"size": 0.184,
		"score": 10
	},
	{
		"name": "管理员",
		"radius": 67.5,
		"size": 0.205,
		"score": 15
	},
	{
		"name": "佩丽卡",
		"radius": 78.0,
		"size": 0.215,
		"score": 21
	},
	{
		"name": "小羊",
		"radius": 100.0,
		"size": 0.35,
		"score": 28
	},
	{
		"name": "小鸟",
		"radius": 115.0,
		"size": 0.183,
		"score": 36
	},
	{
		"name": "弭弗",
		"radius": 130.0,
		"size": 0.57,
		"score": 45
	},
	{
		"name": "奶龙",
		"radius": 160.0,
		"size": 0.604,
		"score": 100
	}
]


const FRUIT_SOUNDS: Array = [
	[],

	[
		"res://sound/音效1.mp3"
	],

	["res://sound/音效2.mp3",
	"res://sound/音效3.mp3",
	"res://sound/音效4.mp3"],

	[],

	[
		"res://sound/音效5.mp3"
	],

	[],
	["res://sound/音效6.mp3"],
	[],
	[],
	["res://sound/音效7.mp3"]
]

const FRUIT_VOLUMES: Array[float] = [
	0.8,  # 1号水果
	2.0,  # 2号水果
	1.0,  # 3号水果
	0.6,  # 4号水果
	0.5,  # 5号水果
	1.0,  # 6号水果
	1.0,  # 7号水果
	1.0,  # 8号水果
	1.0,  # 9号水果
	1.0   # 10号水果
]


# 游戏参数


# 水果生成位置
const SPAWN_Y := 100.0

# 水平移动范围
const MIN_X := 80.0
const MAX_X := 860.0

# 初始随机水果范围
const RANDOM_MIN_LEVEL := 0
const RANDOM_MAX_LEVEL := 3

# 最高判定线 Y 坐标
const GAME_OVER_Y := 250.0


# 游戏状态


var score: int = 0

# 当前玩家控制的水果
var current_fruit: Fruit = null

# 下一颗水果等级
var next_level: int = 0

# 游戏是否结束
var is_game_over: bool = false

var cheat_mode: bool = false


@onready var fruits_container: Node2D = $Node2D/fruits
@onready var score_label: Label = $Node2D/UI/scorelabel
@onready var next_label: Label = $Node2D/UI/nextlabel
@onready var score_image_normal: Sprite2D = $gugugaga
@onready var score_image_active: Sprite2D = $gugugaga2
@onready var game_over_ui: Control = $Node2D/UI/gameover

const SCORE_IMAGE_NORMAL := preload(
	"res://images/d902cee1-50d2-462e-b810-c46def1a05e0.png"
)

const SCORE_IMAGE_ACTIVE := preload(
	"res://images/b5956a68-7539-4bfc-9e94-d8bad70efbc9.png"
)


# 初始化

func _ready() -> void:
	
	score_image_normal.visible = true
	score_image_active.visible = false
	
	
	randomize()

	# 随机决定第一颗水果
	next_level = get_random_fruit_level()

	# 生成水果
	spawn_next_fruit()

	# 更新 UI
	update_score()
	update_next_label()


func _process(_delta: float) -> void:

	if is_game_over:
		return

	if current_fruit == null:
		return

	# 当前水果已经掉下去了
	if not current_fruit.freeze:
		return

	# 获取鼠标位置
	var mouse_position := get_global_mouse_position()

	# 限制水平位置
	var x: float = clamp(
	mouse_position.x,
	MIN_X,
	MAX_X)

	# 只修改 X，不修改 Y
	current_fruit.position.x = x


func _physics_process(_delta: float) -> void:

	if is_game_over:
		return

	for fruit: Fruit in fruits_container.get_children():

		if not is_instance_valid(fruit):
			continue

		if fruit == current_fruit:
			continue

		if not fruit.has_landed:
			continue

		var fruit_top: float = (
			fruit.global_position.y - fruit.radius
		)

		if fruit_top <= GAME_OVER_Y:
			game_over()
			return
			#pass

# 鼠标输入

func _unhandled_input(event: InputEvent) -> void:

	if is_game_over:
		return

	# F 键切换作弊模式
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F:
			cheat_mode = not cheat_mode

			print(
				"作弊模式: ",
				"开启" if cheat_mode else "关闭"
			)

			return

	# 鼠标左键
	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if not event.pressed:
				return

			# 作弊模式
			if cheat_mode:
				remove_clicked_fruit()
				return

			# 正常模式
			drop_fruit()


# 生成下一颗水果

func spawn_next_fruit() -> void:

	if is_game_over:
		return

	# 创建水果
	current_fruit = FRUIT_SCENE.instantiate()

	# 设置水果等级
	current_fruit.fruit_level = next_level

	# 设置水果半径
	current_fruit.radius = FRUIT_DATA[next_level]["radius"]
	current_fruit.sprite_size = FRUIT_DATA[next_level]["size"]

	# 设置位置
	current_fruit.position = Vector2(
		320.0,
		SPAWN_Y
	)

	# 暂时冻结
	current_fruit.freeze = true

	# 玩家控制阶段不允许合成
	current_fruit.can_merge = false

	# 监听合成
	current_fruit.merged.connect(_on_fruits_merged)

	# 加入水果容器
	fruits_container.add_child(current_fruit)

	# 随机生成下一颗水果
	next_level = get_random_fruit_level()

	update_next_label()


# 掉落水果

func drop_fruit() -> void:

	if current_fruit == null:
		return

	current_fruit.freeze = false
	current_fruit.is_dropping = true

	play_fruit_sound(current_fruit.fruit_level)

	var dropped_fruit: Fruit = current_fruit

	current_fruit.can_merge = true
	current_fruit = null

	await get_tree().create_timer(0.5).timeout

	if is_instance_valid(dropped_fruit):
		dropped_fruit.is_dropping = false
		#dropped_fruit.has_landed = true

	if is_game_over:
		return

	spawn_next_fruit()

# 水果合成

func _on_fruits_merged(
	fruit_a: Fruit,
	fruit_b: Fruit
) -> void:
	call_deferred(
		"merge_fruits",
		fruit_a,
		fruit_b
	)

func merge_fruits(
	fruit_a: Fruit,
	fruit_b: Fruit
	) -> void:

	if not is_instance_valid(fruit_a):
		return

	if not is_instance_valid(fruit_b):
		return

	var new_level: int = fruit_a.fruit_level + 1

	var merge_position: Vector2 = (
		fruit_a.global_position +
		fruit_b.global_position
	) / 2.0

	# 删除原来的两个水果
	fruit_a.queue_free()
	fruit_b.queue_free()

	# 达到最高等级
	if new_level >= FRUIT_DATA.size():
		add_score(100)
		return

	# 创建新水果
	var new_fruit: Fruit = FRUIT_SCENE.instantiate()

	new_fruit.fruit_level = new_level
	new_fruit.radius = FRUIT_DATA[new_level]["radius"]
	new_fruit.sprite_size = FRUIT_DATA[new_level]["size"]

	new_fruit.global_position = merge_position
	new_fruit.can_merge = true

	new_fruit.merged.connect(_on_fruits_merged)

	fruits_container.add_child(new_fruit)

# 播放合成后水果的声音
	play_fruit_sound(new_level)

	add_score(
		FRUIT_DATA[new_level]["score"]
	)

# 随机水果

func get_random_fruit_level() -> int:

	return randi_range(
		RANDOM_MIN_LEVEL,
		RANDOM_MAX_LEVEL
	)



# 增加分数


func add_score(amount: int) -> void:

	score += amount
	$for_asb.play()

	update_score()
	
	show_score_image()


# 更新分数 UI


func update_score() -> void:

	if score_label:
		score_label.text = "得分: %d" % score



# 更新下一颗水果 UI


func update_next_label() -> void:

	if next_label:

		var fruit_name: String = FRUIT_DATA[next_level]["name"]

		next_label.text = "下一只: %s" % fruit_name


func play_fruit_sound(fruit_level: int) -> void:

	if fruit_level < 0:
		return

	if fruit_level >= FRUIT_SOUNDS.size():
		return

	if fruit_level >= FRUIT_VOLUMES.size():
		return

	var sounds: Array = FRUIT_SOUNDS[fruit_level]

	# 没有配置声音
	if sounds.is_empty():
		return

	var random_index: int = randi_range(
		0,
		sounds.size() - 1
	)

	var sound_path: String = sounds[random_index]

	if not ResourceLoader.exists(sound_path):
		return

	var stream: AudioStream = load(sound_path)

	if stream == null:
		return

	var player: AudioStreamPlayer = AudioStreamPlayer.new()

	player.stream = stream

	# 设置这个水果的音量
	player.volume_db = linear_to_db(
		FRUIT_VOLUMES[fruit_level]
	)

	player.finished.connect(player.queue_free)

	$Audio.add_child(player)

	player.play()


var score_image_token: int = 0


func show_score_image() -> void:

	if score_image_normal == null:
		return

	if score_image_active == null:
		return

	score_image_token += 1
	var current_token: int = score_image_token

	# 切换到得分图片
	score_image_normal.visible = false
	score_image_active.visible = true

	# 等待 0.5 秒
	await get_tree().create_timer(0.8).timeout

	# 如果这期间没有新的得分
	if current_token == score_image_token:
		score_image_active.visible = false
		score_image_normal.visible = true


func remove_clicked_fruit() -> void:

	var mouse_position: Vector2 = get_global_mouse_position()

	var query := PhysicsPointQueryParameters2D.new()

	query.position = mouse_position
	query.collide_with_bodies = true
	query.collide_with_areas = true

	var results: Array[Dictionary] = (
		get_world_2d().direct_space_state.intersect_point(query)
	)

	for result: Dictionary in results:

		var collider: Object = result.get("collider")

		if collider is Fruit:

			# 不允许删除当前正在控制的水果
			if collider == current_fruit:
				return

			collider.queue_free()

			return


func game_over() -> void:

	if is_game_over:
		return

	is_game_over = true
	$gameoverplayer.play()

	# 停止当前控制的水果
	if current_fruit != null:
		current_fruit.freeze = true
		current_fruit = null

	# 显示结束提示
	game_over_ui.visible = true
