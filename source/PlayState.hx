package;

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

    override public function create():Void {
        super.create();

        var bg:FlxSprite = new FlxSprite();
        bg.loadGraphic("assets/images/bg.png");
        
        // Calculate scale factors to stretch image exactly to screen size
        var scaleX = FlxG.width / bg.frameWidth;
        var scaleY = FlxG.height / bg.frameHeight;
        
        // Apply scale
        bg.scale.set(scaleX, scaleY);
        bg.updateHitbox();
        
        // Top-left corner so it fills from 0,0
        bg.x = 0;
        bg.y = 0;
        
        add(bg);
        

        ground1 = new FlxSprite(0, FlxG.height - 50, "assets/images/ground.png");
        ground1.scale.set(0.5, 0.5);
        ground1.updateHitbox();
        ground1.velocity.x = -100;
        
        ground2 = new FlxSprite(ground1.width, FlxG.height - 50, "assets/images/ground.png");
        ground2.scale.set(0.5, 0.5);
        ground2.updateHitbox();
        ground2.velocity.x = -100;
        
        add(ground1);
        add(ground2);
        

        // Create the bird
        bird = new FlxSprite("assets/images/bird.png");
        bird.acceleration.y = 0; // Keep the bird still at the start
        bird.scale.set(0.1, 0.1); // Scale down the bird size
        bird.updateHitbox();
        bird.x = FlxG.width / 4;
        bird.y = FlxG.height / 2;
        add(bird);

        // Initialize score text
        scoreText = new FlxText(10, 10, 0, "Score: 0", 16);
        scoreText.color = FlxColor.WHITE;
        add(scoreText);
    }

    // Function to generate pipes at random positions
    function generatePipes():Void {
        if (gameOver) return;
        var gapY:Float = FlxG.random.float(100, FlxG.height - 200); // Random Y position for pipe gap
        var gapSize:Float = 150; // Size of the gap between the pipes

        // Create the top pipe
        var pipeTop:FlxSprite = new FlxSprite(FlxG.width, gapY - 200, "assets/images/pipe.png");
        pipeTop.scale.set(0.1, 0.1); // Scaling the pipe for better visibility
        pipeTop.updateHitbox();

        // Create the bottom pipe
        var pipeBottom:FlxSprite = new FlxSprite(FlxG.width, gapY + gapSize, "assets/images/pipe.png");
        pipeBottom.scale.set(0.1, 0.1); // Scaling the pipe for better visibility
        pipeBottom.updateHitbox();

        // Add movement if the game has started
        if (gameStarted) {
            pipeTop.velocity.x = -100; // Move pipes to the left
            pipeBottom.velocity.x = -100; // Move pipes to the left
        }

        // Add pipes to the array and to the game
        pipes.push(pipeTop);
        pipes.push(pipeBottom);
        add(pipeTop);
        add(pipeBottom);
    }

    override public function update(elapsed:Float):Void {
            // Loop ground1
        if (ground1.x + ground1.width < 0) {
            ground1.x = ground2.x + ground2.width;
        }

        // Loop ground2
        if (ground2.x + ground2.width < 0) {
            ground2.x = ground1.x + ground1.width;
        }
        if (!gameOver) {
            // Detect if the space bar is pressed
            if (FlxG.keys.justPressed.SPACE) {
                if (!gameStarted) {
                    gameStarted = true;
                    bird.acceleration.y = gravity; // Start gravity effect when space is pressed
                    new FlxTimer().start(2, function(timer:FlxTimer) {
                        generatePipes(); // Generate pipes periodically
                    }, 0);
                }
                bird.velocity.y = -200; // Move the bird upward when space is pressed
                bird.drag.y = 600;
            }
            
            // Move the pipes and check for collisions
            for (pipe in pipes) {
                if (gameStarted) {
                    pipe.x -= 100 * elapsed; // Move pipes to the left at a constant speed
                }
                if (pipe.x + pipe.width < 0) {
                    pipe.kill(); // Remove pipes when they go off screen
                }
            }

            // Check for collisions with the ground or pipes
            if (bird.overlaps(ground1) || bird.overlaps(ground2) || checkPipeCollision()) {
                endGame(); // End game if the bird hits the ground or pipes
            }
            updateScore();
        }
        super.update(elapsed);
    }

    // Function to check collision with pipes
    function checkPipeCollision():Bool {
        for (pipe in pipes) {
            if (pipe.exists && bird.overlaps(pipe)) {
                return true;
            }
        }
        return false;
    }    

    function updateScore():Void {
        for (pipe in pipes) {
            if (pipe.x < bird.x && pipe.exists) {
                score++;
                scoreText.text = "Score: " + score;
                pipe.kill(); // This also sets exists to false
            }            
        }
    }
    // End the game if a collision occurs
    function endGame():Void {
        gameOver = true;
        bird.acceleration.y = 0; // Stop gravity
        bird.velocity.y = 0; // Stop bird movement
       // bird.animation.stop(); // Stop the bird animation

        // Stop ground movement
        ground1.velocity.x = 0;
        ground2.velocity.x = 0;

        // Stop pipe movement
        for (pipe in pipes) {
            pipe.velocity.x = 0;
        }

        // Create a restart button
        restartButton = new FlxButton(FlxG.width / 2 - 40, FlxG.height / 2, "Restart", function() {
            FlxG.resetState(); // Reset the game to start again
        });
        add(restartButton);
    }
}
