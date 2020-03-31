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
    var vidasBoss2 = [16,16,16]
    let skins = ["capivarinha1","capivarinha2","capivarinha3"]
    let skinBoss2 = ["capivaraBoss23","capivaraBoss22","capivaraBoss21"]
    let skinBoss3 = ["boss1","boss2","boss3"]
    
    let player = SKSpriteNode(imageNamed: "busao2")
    let terra = SKSpriteNode(imageNamed: "terra")
    var pontuacao = SKSpriteNode(texture: SKTexture(imageNamed:"pontuacao"))
    let enemey1 = Capivara(nVida: 1, nNode: SKSpriteNode(imageNamed: "capivarinha1"))
    let enemey2 = Capivara(nVida: 2, nNode: SKSpriteNode(imageNamed: "capivaraBoss21"))
    let enemey3 = Capivara(nVida: 17, nNode: SKSpriteNode(imageNamed: "boss1"))
    var arrayInimigosAcertados : [SKNode] = []
    
    var vidaBoss3 = 25
    var onTap  = false
    var lastUpdate = TimeInterval()
    var shotInterval = TimeInterval(0.3)
    var interval: Double = 0
    var lastShot = TimeInterval()
    var viewController : GameViewController!
    var lastUpdateCap = TimeInterval()
    var shotIntervalCap = TimeInterval(0.4)
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
    var pontos = 0
    let fases: [Fase] = [
        Fase(numeroInimigos: 12, texto: "Fase 1", arrayInimigos: []),
        Fase(numeroInimigos: 18, texto: "Fase 2", arrayInimigos: []),
        Fase(numeroInimigos: 3, texto: "Fase 3", arrayInimigos: []),
        Fase(numeroInimigos: 1, texto: "Fase 4", arrayInimigos: [])
    ]
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    let labelPontos = SKLabelNode(text: "0")
    let labelOrdas = SKLabelNode(text: "0")
    override func didMove(to view: SKView) {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4294975211923841/4305940624")
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
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
    func setuplabelPontos(){
        labelPontos.removeFromParent()
        self.labelPontos.fontName = "AvenirNext-Bold"
        self.labelPontos.fontColor = #colorLiteral(red: 0, green: 0.9960784314, blue: 0, alpha: 1)
        self.labelPontos.fontSize = 20
     
        self.labelPontos.position = CGPoint(x: self.frame.maxX  - 50, y:self.frame.maxY  - 30)
        self.labelPontos.zPosition = 2
        addChild(labelPontos)
    }
    func setuplabelOrdas(){
         labelOrdas.removeFromParent()
        labelOrdas.text = "\(self.contFase + 1)/4"
         self.labelOrdas.fontName = "AvenirNext-Bold"
         self.labelOrdas.fontColor = #colorLiteral(red: 0, green: 0.9960784314, blue: 0, alpha: 1)
         self.labelOrdas.fontSize = 20
      
         self.labelOrdas.position = CGPoint(x: self.frame.minX  + 50, y:self.frame.maxY  - 30)
         self.labelOrdas.zPosition = 2
         addChild(labelOrdas)
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
    
    
    
    func didBegin(_ contact: SKPhysicsContact ) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        guard nodeB.name == "enemy" || nodeA.name == "enemy" || nodeA.name == "terra" || nodeB.name == "terra" || nodeA.name == "player" || nodeB.name == "player" || nodeA.name == "shotCap" || nodeB.name == "shotCap" || nodeA.name == "enemy2" || nodeB.name == "enemy2" || nodeA.name == "enemy3" || nodeB.name == "enemy3" else{return}
        
        
        
        let nomeA = nodeA.name?.description
        let nomeB = nodeB.name?.description
        
        
        
        if (nomeA == "enemy" && nomeB == "shotCap") || (nomeA == "shotCap" && nomeB == "enemy"){
        }
        else if (nomeA == "terra" && nomeB == "shotCap") || (nomeA == "shotCap" && nomeB == "terra"){
            
            let firstNode = nodeA
            let secondNode = nodeB
            if let explosion = SKEmitterNode(fileNamed: "ExplosionInEarth") {
                
                explosion.zPosition = 1
                if firstNode.name != "terra"{
                    firstNode.removeFromParent()
                    explosion.position = firstNode.position
                 }
                else{
                    secondNode.removeFromParent()
                    explosion.position = secondNode.position
                }
                explosion.position.y -= 70

                addChild(explosion)

            }
            
            self.tirosNaTerra += 1
            if self.tirosNaTerra == 3{
                self.terra.texture = SKTexture(imageNamed: "terra2")
                
            }
            else if self.tirosNaTerra == 5{
                self.terra.texture = SKTexture(imageNamed: "terra3")
                
            }
            else if self.tirosNaTerra == 10{
                self.terra.texture = SKTexture(imageNamed: "terra4")
                
            }
            else if self.tirosNaTerra == 20{
                self.terra.texture = SKTexture(imageNamed: "terra5")
                 if let smoke1 = SKEmitterNode(fileNamed: "smokeTerra1") {
                    smoke1.position = terra.position
                    smoke1.position.y -= 30
                    smoke1.zPosition = 1
                    self.addChild(smoke1)
                }
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
                self.pontos += 1
                self.labelPontos.text = "\(pontos)"
                self.numInimigosLocal -= 1
                addChild(explosion)
            }
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
        else if (nomeA == "shot" && nomeB == "enemy2") || (nomeA == "enemy2" && nomeB == "shot"){
            
            var nodeShot: SKNode
            var nodeEnemy: SKNode
            if nomeA == "shot"{
                nodeShot = nodeA
                nodeEnemy = nodeB
            }
            else{
                nodeShot = nodeB
                nodeEnemy = nodeA
            }
            
            var tem = false
            self.arrayInimigosAcertados.forEach({elem in
                if elem.position.x == nodeEnemy.position.x{
                    tem = true
                    if nodeEnemy.position.x < -100{
                        
                        self.vidasBoss2[0] -= 1
                        let firstNode = nodeA
                        let secondNode = nodeB
                        if let explosion = SKEmitterNode(fileNamed: "ExplosionInEarth") {
                            explosion.position = firstNode.position
                            explosion.position.y += 25
                            explosion.zPosition = 1
                            self.labelPontos.text = "\(pontos)"
                            addChild(explosion)
                        }
                        if firstNode.name == "shot"{
                            firstNode.removeFromParent()

                        }
                        else{
                            secondNode.removeFromParent()
                        }
                        if self.vidasBoss2[0] == 0 {
                            if let explosion = SKEmitterNode(fileNamed: "ExplosionBoss1") {
                                explosion.position = nodeEnemy.position
                                explosion.position.y += 25
                                explosion.zPosition = 1
                                self.pontos += 5
                                self.labelPontos.text = "\(pontos)"
                                addChild(explosion)
                            }
                            self.numInimigosLocal -= 1
                            firstNode.removeFromParent()
                            secondNode.removeFromParent()
                            nodeEnemy.removeFromParent()
                            nodeShot.removeFromParent()
                        }
                    }
                    else if nodeEnemy.position.x < 0{
                        
                        self.vidasBoss2[1] -= 1
                        let firstNode = nodeA
                        let secondNode = nodeB
                        if let explosion = SKEmitterNode(fileNamed: "ExplosionInEarth") {
                            explosion.position = firstNode.position
                            explosion.position.y += 25
                            explosion.zPosition = 1
                            self.labelPontos.text = "\(pontos)"
                            addChild(explosion)
                        }
                        if firstNode.name == "shot"{
                            firstNode.removeFromParent()

                        }
                        else{
                            secondNode.removeFromParent()
                        }
                        if self.vidasBoss2[1] == 0 {
                            if let explosion = SKEmitterNode(fileNamed: "ExplosionBoss1") {
                                explosion.position = firstNode.position
                                explosion.position.y += 25
                                explosion.zPosition = 1
                                self.pontos += 5
                                self.labelPontos.text = "\(pontos)"
                                addChild(explosion)
                            }
                            self.numInimigosLocal -= 1
                            firstNode.removeFromParent()
                            secondNode.removeFromParent()
                            nodeEnemy.removeFromParent()
                            nodeShot.removeFromParent()
                        }
                    }
                    else{
                        
                        self.vidasBoss2[2] -= 1
                        let firstNode = nodeA
                        let secondNode = nodeB
                        if let explosion = SKEmitterNode(fileNamed: "ExplosionInEarth") {
                            explosion.position = nodeEnemy.position
                            explosion.position.y += 25
                            explosion.zPosition = 1
                            self.labelPontos.text = "\(pontos)"
                            addChild(explosion)
                        }
                        if firstNode.name == "shot"{
                            firstNode.removeFromParent()

                        }
                        else{
                            secondNode.removeFromParent()
                        }
                        if self.vidasBoss2[2] == 0 {
                            if let explosion = SKEmitterNode(fileNamed: "ExplosionBoss1") {
                                explosion.position = nodeEnemy.position
                                explosion.position.y += 25
                                explosion.zPosition = 1
                                self.pontos += 5
                                self.labelPontos.text = "\(pontos)"
                                addChild(explosion)
                            }
                            self.numInimigosLocal -= 1
                            firstNode.removeFromParent()
                            secondNode.removeFromParent()
                            nodeEnemy.removeFromParent()
                            nodeShot.removeFromParent()
                        }
                    }
                }
            })
            if !tem{
                self.arrayInimigosAcertados.append(nodeEnemy)
            }
            tem = false
        }
        else if (nomeA == "shot" && nomeB == "enemy3") || (nomeA == "enemy3" && nomeB == "shot"){
            self.vidaBoss3 -= 1
            let firstNode = nodeA
            let secondNode = nodeB
            if let explosion = SKEmitterNode(fileNamed: "ExplosionInEarth") {
                if nomeA == "enemy3"{
                    explosion.position = firstNode.position
                }
                else{
                    explosion.position = secondNode.position
                }
                explosion.zPosition = 1
                self.labelPontos.text = "\(pontos)"
                addChild(explosion)
                if firstNode.name == "shot"{
                    firstNode.removeFromParent()
                }
                else{
                     secondNode.removeFromParent()
                }
            }
            if vidaBoss3 == 0 {
                if let explosion = SKEmitterNode(fileNamed: "ExplosionBigBoss") {
                    if firstNode.name == "enemy3"{
                         explosion.position = firstNode.position
                    }
                    else{
                        explosion.position = secondNode.position
                    }
                    explosion.position.y += 25
                    explosion.zPosition = 1
                    self.pontos += 5
                    self.labelPontos.text = "\(pontos)"
                    addChild(explosion)
                }
                firstNode.removeFromParent()
                secondNode.removeFromParent()
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (Timer) in
                    self.numInimigosLocal -= 1
                }
                
            }
        }
        else if (nomeA == "shotCap" && nomeB == "player") || (nomeA == "player" && nomeB == "shotCap"){
            // tiro capivara com nave
            self.player.texture = SKTexture(imageNamed: "busaoEscudo1")
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (Timer) in
                self.player.texture = SKTexture(imageNamed: "busao2")
            }
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
        self.pontuacao = SKSpriteNode(texture: SKTexture(imageNamed: "pontuacao"), size: CGSize(width: view!.frame.width, height: 70))
        self.pontuacao.position = CGPoint(x: 0 , y: (view!.frame.height / 2) - 15)
        addChild(self.pontuacao)
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
        setuplabelPontos()
        setuplabelOrdas()
        let initialX2 =  view!.frame.width * -0.40
        let initialY2 =  view!.frame.height * 0.35
        moveEnemy.timingMode = .easeInEaseOut
        moveEnemy2.timingMode = .easeInEaseOut
        let seqEnemy = SKAction.sequence([moveEnemy,moveEnemy2])
        let looping = SKAction.repeatForever(seqEnemy)
        var posicaoX = initialX2
        var posicaoY = initialY2

        for _ in 0...self.fases[contFase].numeroInimigos - 1{
            let wait = SKAction.wait(forDuration: interval)
            interval += 0.03
            var enemyCopy: SKSpriteNode!
            
            if contFase < 2{
                enemyCopy = self.enemey1.node.copy() as? SKSpriteNode
                enemyCopy.texture = SKTexture(imageNamed: self.skins.randomElement()!)
                enemyCopy.physicsBody = SKPhysicsBody(rectangleOf: enemey1.node.texture!.size())
                enemyCopy.name = "enemy"
            }
                
            else if contFase < 3{
                enemyCopy = self.enemey2.node.copy() as? SKSpriteNode
                enemyCopy.texture = SKTexture(imageNamed: self.skinBoss2.randomElement()!)
                enemyCopy.physicsBody = SKPhysicsBody(rectangleOf: enemey2.node.texture!.size())
                enemyCopy.name = "enemy2"
            }
                
            else {
                enemyCopy = self.enemey3.node.copy() as? SKSpriteNode
                enemyCopy.texture = SKTexture(imageNamed: self.skinBoss3.randomElement()!)
                enemyCopy.physicsBody = SKPhysicsBody(rectangleOf: enemey3.node.texture!.size())
                 enemyCopy.name = "enemy3"
            }
            enemyCopy.run(SKAction.sequence([wait,looping]))
            let larguraInimigo = enemyCopy.frame.width
            let alturaInimigo = enemyCopy.frame.height
            
            let limite = view!.frame.width / 2
            
            if posicaoX > limite {
                posicaoY -= alturaInimigo + 10
                posicaoX = initialX2
            }
            
            if contFase < 2{
                enemyCopy.position = CGPoint(x: posicaoX , y:  posicaoY )
            }
            else if contFase < 3{
                enemyCopy.position = CGPoint(x: posicaoX + 30 , y:  posicaoY - 40 )
            }
            else{
                enemyCopy.position = CGPoint(x: self.frame.midX , y:  view!.frame.height / 3.5 )
            }
            enemyCopy.zPosition = 1
            enemyCopy.physicsBody?.usesPreciseCollisionDetection = true
            enemyCopy.physicsBody?.categoryBitMask = 1
            enemyCopy.physicsBody?.collisionBitMask = 0
            self.fases[contFase].arrayInimigos.append(enemyCopy)
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (Timer) in
                self.addChild(enemyCopy)
            }
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
                    if interstitial.isReady {
                        interstitial.present(fromRootViewController:self.viewController )
                    }
                    else{
                        trocarFase()

                    }
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



