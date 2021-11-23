Hello, in order to get car driving and camera controllers work, You should import firstly those free Unity assets into project:

1. Vehicles from Standard Assets pack
2. Cameras from Standard Assets pack

And after that You can import RealisticCar_HD and it should work well by default.
If there will be any problem with Car scripts or anything, make sure You have imported those assets first.
And then reimport Car package or reopen "Demo_Driving" scene, it will refresh all scripts and should work.


If you would have any questions, feel free to ask at: darek.slanda@gmail.com


If You want to change anything with the Car controller, follow the CarGuidelines from Unity Vehicles Standard Asset.

In Demo_Driving scene only one car has enabled Car User Control script. 
So by default, player can controll only one Car, but if You want controll any other car, 
just enable all Car Control scripts in selected prefab and set tag as a Player 
and untagg previous car and disable Car User Control script, so camera can find which car is controlled by player at the time.

Car has 4 openable doors. Just select "Car02_Door_BackLeft" or any other door under "Car02_Body" and rotate it in Y axis.
Doors don't have any animations or scripts applied for opening and closing, the same is about Windshield wipers, Steering Wheel and
Speedometer Pointers, If You want to make them live, You need to make animations or move them via scripts. 


Car controller is included in prefabs with "_Driving_" in name.
Car prefabs with "_Static_" in name are only static models, with LOD's implemented.

If You want to use this car in mobile game, You can use LOD1 or LOD2. 

Car model is aligned properly facing positive Z axis. Each car wheel and stering wheel is separated and alighend properly. 
You can find separated wheel model in meshes folder, just in case if You would like to use this wheel in some other cars or anything. 

All textures including "Metallic" in name have diffrent texture in each RGBA Channel:
R: Metallic
G: Occlusion
B: -----
A: Smothness

Additionally You can find separated Occlusion textures and source PSD's if You would like to change anything.

If You want to make your own material using those textures, please apply Metallic Textures into Metallic and Occlusion slots and for Smothness please set "Metallic Alpha"

Main Body part includes 2 materials. One for Car paint (RealisticCar02_Body - You can adjust color, metallic and smothness freely. 
Also You can make Your own custom paint texture using Car02_Body_PSD file) and second for everything else 
(Car02_Parts - Color, metallic and smothness are defined by textures. You can find 2 different texture sets for the parts, one has Chromed details and another has black plastic)

For body material You can apply any color You want in Albedo and set Metallic and Smothness as You want. I have made some materials with diffrent colors. 
If You need You can just copy one of them, change color or anything else and apply it the body part of the car.

All prefabs have LOD's applied and set properly, so if You want to change material in body, You have to apply it for all LOD levels. 
If You apply diffrent material only for LOD0, model will change its material for old one when zoomed out. The same thing is about Wheels.

Car model also includes meshes for Lights Flares. All light groups are separated objects (Normal Lights, Brake Lights, Turn Lights) 
and you can enable any of them by enabling mesh renderer. Brake Lights works with standard script from Car controller.