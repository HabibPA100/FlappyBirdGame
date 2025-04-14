package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PlayState extends FlxState {
    var bird:FlxSprite;
    var ground1:FlxSprite;
    var ground2:FlxSprite;
    var pipes:Array<FlxSprite> = [];
    var scoreText:FlxText;
    var score:Int = 0;
    var gravity:Float = 400;
    var gameStarted:Bool = false;
    var gameOver:Bool = false;
    var restartButton:FlxButton;
	var birdDestroy:FlxSprite;

    override public function create():Void {
        super.create();
		// Background music
		FlxG.sound.playMusic(AssetPaths.bgMusic__mp3);
		// Background
        var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic("assets/images/background.jpg");
		bg.scale.set(FlxG.width / bg.frameWidth, FlxG.height / bg.frameHeight);
		bg.updateHitbox();
        bg.x = 0;
		bg.y = 0;
        add(bg);

		// Ground
        ground1 = new FlxSprite(0, FlxG.height - 50, "assets/images/ground.png");
        ground1.scale.set(0.5, 0.5);
		ground1.updateHitbox();
		ground1.velocity.x = -200;

		ground2 = new FlxSprite(ground1.width - 5, FlxG.height - 50, "assets/images/ground.png");
        ground2.scale.set(0.5, 0.5);
		ground2.updateHitbox();
		ground2.velocity.x = -200;

		// Bird
        bird = new FlxSprite("assets/images/bird.png");
		bird.acceleration.y = 0;
		bird.scale.set(0.1, 0.1);
        bird.updateHitbox();
        bird.x = FlxG.width / 4;
		bird.y = FlxG.height / 2;
		// Bird Destroy
		birdDestroy = new FlxSprite(0, 0);
		birdDestroy.loadGraphic(AssetPaths.bust__png, true, 200, 200);
		birdDestroy.animation.add('destroyBird', [0, 1, 2, 3], 5, false);

		// Score Text
		scoreText = new FlxText(FlxG.width / 2 - 50, 100, 150, "Score: 0", 16);
        scoreText.color = FlxColor.WHITE;
		// Add in correct layer order
		add(ground1);
		add(ground2);
		add(bird);
        add(scoreText);
    }

    function generatePipes():Void {
		if (gameOver)
			return;

		var gapSize:Float = 150;
		var gapY:Float = FlxG.random.float(150, FlxG.height - gapSize - 100);

		var pipeTop:FlxSprite = new FlxSprite(FlxG.width, 0, "assets/images/topPipe.png");
		pipeTop.scale.set(0.1, 0.1);
        pipeTop.updateHitbox();

		var pipeBottom:FlxSprite = new FlxSprite(FlxG.width, gapY + gapSize, "assets/images/pipe.png");
		pipeBottom.scale.set(0.1, 0.1);
		pipeBottom.updateHitbox();

        if (gameStarted) {
			pipeTop.velocity.x = -100;
			pipeBottom.velocity.x = -100;
        }

        pipes.push(pipeTop);
        pipes.push(pipeBottom);
		// Add pipes first (so they go behind the ground)
        add(pipeTop);
        add(pipeBottom);
		// Re-add ground so it appears above pipes
		remove(ground1);
		remove(ground2);
		add(ground1);
		add(ground2);
    }

    override public function update(elapsed:Float):Void {
		// Ground looping
		if (ground1.x + ground1.width < 0)
			ground1.x = ground2.x + ground2.width;

		if (ground2.x + ground2.width < 0)
            ground2.x = ground1.x + ground1.width;
		if (!gameOver)
		{
			if (FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed)
			{
                if (!gameStarted) {
                    gameStarted = true;
					bird.acceleration.y = gravity;
                    new FlxTimer().start(2, function(timer:FlxTimer) {
						generatePipes();
                    }, 0);
                }
				bird.velocity.y = -200;
                bird.drag.y = 600;
            }

			// Move pipes and handle collisions
            for (pipe in pipes) {
				if (gameStarted)
					pipe.x -= 100 * elapsed;

				if (pipe.x + pipe.width < 0)
					pipe.kill();
            }

            if (bird.overlaps(ground1) || bird.overlaps(ground2) || checkPipeCollision()) {
				endGame();
            }

            updateScore();
        }

        super.update(elapsed);
    }

    function checkPipeCollision():Bool {
        for (pipe in pipes) {
            if (pipe.exists && bird.overlaps(pipe)) {
                return true;
            }
        }
        return false;
	}

	function updateScore():Void
	{
		for (i in 0...pipes.length)
		{
			var pipe = pipes[i];

			if (i % 2 == 0 && pipe.x + pipe.width < bird.x && pipe.exists)
			{
				FlxG.camera.flash(FlxColor.GREEN, 1);
                score++;
				scoreText.text = "Score: " + score;
				pipe.kill();
				if (i + 1 < pipes.length && pipes[i + 1].exists)
					pipes[i + 1].kill();
			}
        }
    }

    function endGame():Void {
        gameOver = true;
		// bird.acceleration.y = 0;
		// bird.velocity.y = 0;
		FlxG.sound.play(AssetPaths.bust__wav);
		var birdX = bird.x;
		var birdY = bird.y;
		birdDestroy.x = birdX;
		birdDestroy.y = birdY;
		birdDestroy.animation.play("destroyBird");
		add(birdDestroy);
		bird.kill();
		FlxG.camera.shake(0.05, 0.5);

        ground1.velocity.x = 0;
        ground2.velocity.x = 0;

        for (pipe in pipes) {
            pipe.velocity.x = 0;
        }

        restartButton = new FlxButton(FlxG.width / 2 - 40, FlxG.height / 2, "Restart", function() {
			FlxG.resetState();
        });
        add(restartButton);
    }
}
