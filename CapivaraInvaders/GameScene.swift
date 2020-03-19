//
//  GameScene.swift
//  CapivaraInvaders
//
//  Created by Mateus Nunes on 03/03/20.
//  Copyrght © 2020 Mateus Nunes. All rights reserved.
//
import SpriteKit
import GameplayKit
import UIKit
import GoogleMobileAds
 class GameScene: SKScene, SKPhysicsContactDelegate, GADInterstitialDelegate {
    var interstitial: GADInterstitial!
    
    let skins = ["capivarinha1","capivarinha2","capivarinha3"]
    let player = SKSpriteNode(imageNamed: "busao2")
    let terra = SKSpriteNode(imageNamed: "terra")
    let enemy = SKSpriteNode(imageNamed: "capivarinha1")
    let nodes: [SKShapeNode] = []
    var onTap  = false
    var lastUpdate = TimeInterval()
    var shotInterval = TimeInterval(0.4)
    var interval: Double = 0
    var lastShot = TimeInterval()
    var viewController : GameViewController!
    var lastUpdateCap = TimeInterval()
    var shotIntervalCap = TimeInterval(0.6)
    var intervalCap: Double = 0
    var lastShotCap = TimeInterval()
    var numInimigosLocal = 0
    var trocouFase = false
    var contFase = 0
    let moveEnemy = SKAction.moveBy(x: 0, y: 15, duration: 0.7)
    let moveEnemy2 = SKAction.moveBy(x: 0, y: -15, duration: 0.7)
    var terraExplodiu = false
    var tirosNaTerra = 0
    var initialCarregou =  false
    var jogando = false
    var background = false
    let fases: [Fase] = [
        Fase(numeroInimigos: 12, texto: "Fase 1", arrayInimigos: []),
        Fase(numeroInimigos: 18, texto: "Fase 2", arrayInimigos: []),
        Fase(numeroInimigos: 24, texto: "Fase 3", arrayInimigos: []),
        Fase(numeroInimigos: 30, texto: "Fase 4", arrayInimigos: [])
    ]
    let generator = UIImpactFeedbackGenerator(style: .heavy)

    override func didMove(to view: SKView) {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        if let particles = SKEmitterNode(fileNamed: "Starfield"){
            particles.position = CGPoint(x: 0, y: 1080)
            particles.advanceSimulationTime(60)
            particles.zPosition = -2
            addChild(particles)
        }
        inicio()
    }
    @objc func appMovedToBackground() {
        print("App moved to background!")
        background  = true
    }
    
    func disparaPlayer(view:SKView){
        
        let shot = SKSpriteNode(imageNamed: "missil")
        shot.name = "shot"
        let move = SKAction.moveTo(y: 500, duration: 0.4)
        shot.position = player.position
        shot.physicsBody = SKPhysicsBody(rectangleOf: shot.texture!.size())
        shot.physicsBody?.isDynamic = true
        shot.physicsBody?.collisionBitMask = 0
        shot.physicsBody?.contactTestBitMask = 1
        
        shot.run(move)
        self.addChild(shot)
        let recoilTras = SKAction.moveTo(y: view.frame.height * -0.35 - 5, duration: 0.05)
        let recoilFrente = SKAction.moveTo(y: view.frame.height * -0.35 + 5, duration: 0.05)
        let seq = SKAction.sequence([recoilTras,recoilFrente])
        self.player.run(seq)
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { (Timer) in
            shot.removeFromParent()
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        guard nodeB.name == "enemy" || nodeA.name == "enemy" || nodeA.name == "terra" || nodeB.name == "terra" || nodeA.name == "player" || nodeB.name == "player" || nodeA.name == "shotCap" || nodeB.name == "shotCap" else{return}
        
        
        
        let nomeA = nodeA.name?.description
        let nomeB = nodeB.name?.description
        
        
        
        if (nomeA == "enemy" && nomeB == "shotCap") || (nomeA == "shotCap" && nomeB == "enemy"){
        }
        else if (nomeA == "terra" && nomeB == "shotCap") || (nomeA == "shotCap" && nomeB == "terra"){
            self.tirosNaTerra += 1
            print(tirosNaTerra)
            if self.tirosNaTerra == 3{
                self.terra.texture = SKTexture(imageNamed: "terra2")
                
            }
            else if self.tirosNaTerra == 5{
                self.terra.texture = SKTexture(imageNamed: "terra3")
                print("smokeTerra")
                if let smoke1 = SKEmitterNode(fileNamed: "smokeTerra1") {
                    smoke1.position = terra.position
                    smoke1.zPosition = 1
                    self.addChild(smoke1)
                }
            }
            else if self.tirosNaTerra == 10{
                self.terra.texture = SKTexture(imageNamed: "terra4")
                
            }
            else if self.tirosNaTerra == 20{
                self.terra.texture = SKTexture(imageNamed: "terra5")
            }
            else if self.tirosNaTerra == 30{
                self.terra.texture = SKTexture(imageNamed: "terra6")
            }
            else if self.tirosNaTerra == 40{
                let firstNode = nodeA
                let secondNode = nodeB
                if let explosion = SKEmitterNode(fileNamed: "ExploTerra") {
                    explosion.position = firstNode.position
                    explosion.zPosition = 1
                    self.addChild(explosion)
                }
                firstNode.removeFromParent()
                secondNode.removeFromParent()
                if let explosion1 = SKEmitterNode(fileNamed: "ExploTerra") {
                    explosion1.position = player.position
                    explosion1.zPosition = 1
                    self.addChild(explosion1)
                    player.removeFromParent()
                    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (Timer) in
                        self.gameOver()
                    }
                }
            }
        }
        else if (nomeA == "shot" && nomeB == "enemy") || (nomeA == "enemy" && nomeB == "shot"){
            
            let firstNode = nodeA
            let secondNode = nodeB
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position
                explosion.zPosition = 1
                self.numInimigosLocal -= 1
                addChild(explosion)
            }
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
        else if (nomeA == "shotCap" && nomeB == "player") || (nomeA == "player" && nomeB == "shotCap"){
            // tiro capivara com nave
            
            generator.impactOccurred(intensity: 2)

            if nomeA == "shotCap"{
                nodeA.removeFromParent()
            }
            else if nomeB == "shotCap"{
                nodeB.removeFromParent()
            }
        }
    }
    func initialSetup(){
        self.removeAllChildren()
        if let particles = SKEmitterNode(fileNamed: "Starfield"){
            particles.position = CGPoint(x: 0, y: 1080)
            particles.advanceSimulationTime(60)
            particles.zPosition = -2
            addChild(particles)
        }
        contFase = 0
        tirosNaTerra = 0
        self.numInimigosLocal = self.fases[contFase].numeroInimigos
        terra.texture = SKTexture(imageNamed: "terra")
        terra.name = "terra"
        terra.zPosition = -1
        terra.alpha = 1
        terra.position = CGPoint(x: 0, y: -360)
        terra.size = CGSize(width: view!.frame.width, height: view!.frame.height * 0.5)
        terra.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1000, height: 50))
        terra.physicsBody?.usesPreciseCollisionDetection = false
        terra.physicsBody?.categoryBitMask = 1
        terra.physicsBody?.collisionBitMask = 0
        terra.zPosition = 1
        addChild(terra)
        player.position = CGPoint(x: 0, y: view!.frame.height * -0.35 )
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 100))
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.collisionBitMask = 0
        player.name = "player"
        addChild(player)
        setup()
    }
    func gameOver(){
        self.removeAllChildren()
        let label = SKLabelNode(text: "You Lose!")
        if let particles = SKEmitterNode(fileNamed: "Starfield"){
            particles.position = CGPoint(x: 0, y: 1080)
            particles.advanceSimulationTime(60)
            
            particles.zPosition = -2
            
            addChild(particles)
        }
        label.fontName = "AvenirNext-Bold"
        label.color = UIColor.white
        label.fontSize = 50
        label.position = CGPoint(x: 0, y: 0)
        label.zPosition = 1
        addChild(label)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (Timer) in
            self.viewController.buildScene()
        }
    }
    func inicio(){
        let label = SKLabelNode(text: "Tap To Play")
        if let particles = SKEmitterNode(fileNamed: "Starfield"){
            particles.position = CGPoint(x: 0, y: 1080)
            particles.advanceSimulationTime(60)
            particles.zPosition = -2
            addChild(particles)
        }
        label.fontName = "AvenirNext-Bold"
        label.color = UIColor.white
        label.fontSize = 50
        label.position = CGPoint(x: 0, y: 0)
        label.zPosition = 1
        addChild(label)
    }
    func win(){
        
        self.removeAllChildren()
        let label = SKLabelNode(text: "You Won!")
        if let particles = SKEmitterNode(fileNamed: "Starfield"){
            particles.position = CGPoint(x: 0, y: 1080)
            particles.advanceSimulationTime(60)
            particles.zPosition = -2
            addChild(particles)
        }
        label.fontName = "AvenirNext-Bold"
        label.color = UIColor.white
        label.fontSize = 50
        label.position = CGPoint(x: 0, y: 0)
        label.zPosition = 1
        addChild(label)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (Timer) in
            self.viewController.buildScene()
        }
    }
    func setup(){
        let initialX2 =  view!.frame.width * -0.40
        let initialY2 =  view!.frame.height * 0.409
        moveEnemy.timingMode = .easeInEaseOut
        moveEnemy2.timingMode = .easeInEaseOut
        let seqEnemy = SKAction.sequence([moveEnemy,moveEnemy2])
        let looping = SKAction.repeatForever(seqEnemy)
        var posicaoX = initialX2
        var posicaoY = initialY2
        for _ in 0...self.fases[contFase].numeroInimigos - 1{
            let wait = SKAction.wait(forDuration: interval)
            interval += 0.03
            let enemyCopy = self.enemy.copy() as! SKSpriteNode
            enemyCopy.texture = SKTexture(imageNamed: self.skins.randomElement()!)
            enemyCopy.run(SKAction.sequence([wait,looping]))
            let larguraInimigo = enemyCopy.frame.width
            let alturaInimigo = enemyCopy.frame.height
            if posicaoX > view!.frame.width / 2  {
                posicaoY -= alturaInimigo + 10
                posicaoX = initialX2
            }
            enemyCopy.position = CGPoint(x: posicaoX , y:  posicaoY )
            enemyCopy.name = "enemy"
            enemyCopy.zPosition = 1
            self.fases[contFase].arrayInimigos.append(enemyCopy)
            enemyCopy.physicsBody = SKPhysicsBody(rectangleOf: enemy.texture!.size())
            enemyCopy.physicsBody?.usesPreciseCollisionDetection = true
            enemyCopy.physicsBody?.categoryBitMask = 1
            enemyCopy.physicsBody?.collisionBitMask = 0
            addChild(enemyCopy)
            posicaoX += larguraInimigo + 10
        }
    }
    func capivaraShot(){
        if jogando {
            let shotCap = SKSpriteNode(texture: SKTexture(imageNamed: "laser"))
            shotCap.name = "shotCap"
            let move = SKAction.moveTo(y: -500, duration: 0.8)
            let enemies = self.fases[contFase].arrayInimigos.filter({$0.parent != nil})
            if let node = enemies.randomElement(){
                shotCap.position = node.position
                shotCap.physicsBody = SKPhysicsBody(rectangleOf: shotCap.texture!.size())
                //fisica shot capivara = shotPlayer
                shotCap.physicsBody?.isDynamic = true
                shotCap.physicsBody?.collisionBitMask = 0
                shotCap.physicsBody?.contactTestBitMask = 1
                shotCap.zPosition = 1
                shotCap.blendMode = SKBlendMode.add
                shotCap.colorBlendFactor = 10.0
                shotCap.color = UIColor.red
                shotCap.alpha = 1
                shotCap.run(move)
                self.addChild(shotCap)
                Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { (Timer) in
                    shotCap.removeFromParent()
                }
            }
        }
    }
    func trocarFase(){
        
        
        
        if trocouFase{
            if self.contFase == self.fases.count{
                self.contFase = 0
            }
            if self.contFase == self.fases.count - 1 {
                if initialCarregou == false{
                    initialSetup()
                    initialCarregou = true
                }
            }
            setup()
            trocouFase = false
        }
        return
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            player.position.x = touch.location(in:self ).x
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if jogando == false{
            jogando = true
        }
        self.onTap = true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.onTap = false
    }
    
    
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        trocarFase()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if jogando && initialCarregou == false {
            initialSetup()
            initialCarregou = true
        }
        if jogando{
            if self.numInimigosLocal == 0 {
                self.trocouFase = true
                if contFase == self.fases.count {
                    
                    if !terraExplodiu{
                        jogando = false
                        self.win()
                    }
                }
                else if contFase < self.fases.count{
                    self.contFase += 1
                }
                if contFase != self.fases.count {
                    self.numInimigosLocal = self.fases[contFase].numeroInimigos
                    trocarFase()
//                    if interstitial.isReady {
//                        interstitial.present(fromRootViewController:self.viewController )
//                    }
//                    else{
//                        trocarFase()
//
//                    }
                    
                    
                }
            }
            
        }
        //another logic
        
        if lastUpdate == 0{
            lastUpdate = currentTime
            return
        }
        if lastUpdateCap == 0{
            lastUpdateCap = currentTime
            return
        }
        
        let dTime = currentTime - lastUpdate
        lastUpdate = currentTime
        lastShot += dTime
        
        
        let dTimeCap = currentTime - lastUpdateCap
        lastUpdateCap = currentTime
        lastShotCap += dTimeCap
        
        
        
        
        
        if lastShot > shotInterval{
            
            if onTap{
                print("Dis\(currentTime)para")
                disparaPlayer(view: self.view!)
            }
            lastShot -= shotInterval
        }
        
        if lastShotCap > shotIntervalCap{
            //capivara atirar
            if jogando{
                capivaraShot()
            }
            
            lastShotCap -= shotIntervalCap
        }
        
        
    }
}



