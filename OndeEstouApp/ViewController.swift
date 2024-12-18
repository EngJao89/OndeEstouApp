//
//  ViewController.swift
//  OndeEstouApp
//
//  Created by João Ricardo Martins Ribeiro on 20/11/24.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapa: MKMapView!
    var gerenciadorLocalizacao = CLLocationManager()
    var viagem: Dictionary<String, String> = [:]
    var indiceSelecionado: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let indice = indiceSelecionado {
            
            if indice == -1 {//adicionar
                
               configuraGerenciadorLocalizacao()
                
            }else{//listar
                
                exibirAnotacao( viagem: viagem )
                
            }
            
        }
        
        
        //reconhecedor de gestos
        let reconhecedorGesto = UILongPressGestureRecognizer(target: self, action: #selector( ViewController.marcar(gesture:) ))
        reconhecedorGesto.minimumPressDuration = 2
        
        mapa.addGestureRecognizer( reconhecedorGesto )
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let local = locations.last else {
            print("Nenhuma localização disponível.")
            return
        }
        
        exibirLocal(latitude: local.coordinate.latitude, longitude: local.coordinate.longitude)
    }
    
    func exibirLocal(latitude: Double, longitude: Double) {
        let localizacao = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let regiao = MKCoordinateRegion(center: localizacao, span: span)
        
        mapa?.setRegion(regiao, animated: true)
    }
    
    func exibirAnotacao( viagem: Dictionary<String, String> ){
        
        if let localViagem = viagem["local"] {
            if let latitudeS = viagem["latitude"] {
                if let longitudeS = viagem["longitude"] {
                    if let latitude = Double(latitudeS) {
                        if let longitude = Double(longitudeS) {
                            
                            let anotacao = MKPointAnnotation()
                            
                            anotacao.coordinate.latitude = latitude
                            anotacao.coordinate.longitude = longitude
                            anotacao.title = localViagem
                            
                            self.mapa.addAnnotation(anotacao)
                            
                            exibirLocal(latitude: latitude, longitude: longitude)
                            
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func marcar(gesture: UIGestureRecognizer){
        
        if gesture.state == UIGestureRecognizer.State.began {
            
            //Recupera as coordenadas do ponto selecionado
            let pontoSelecionado = gesture.location(in: self.mapa)
            let coordenadas = mapa.convert( pontoSelecionado , toCoordinateFrom: self.mapa)
            let localizacao = CLLocation(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
            
            //recupera endereço do ponto selecionado
            var localCompleto = "Endereço não encontrado!!"
            CLGeocoder().reverseGeocodeLocation( localizacao , completionHandler: { (local, erro) in
                
                if erro == nil {
                    
                    if let dadosLocal = local?.first {
                        
                        if let nome = dadosLocal.name {
                            localCompleto = nome
                        }else{

                            if let endereco = dadosLocal.thoroughfare {
                                localCompleto = endereco
                            }
                            
                        }
                        
                    }
                    
                    //Salvar dados no dispositivo
                    self.viagem = ["local": localCompleto , "latitude": String(coordenadas.latitude) , "longitude": String(coordenadas.longitude) ]
                    ArmazenamentoDados().salvarViagem( viagem: self.viagem )
                    
                    //Exibe anotação com os dados de endereco
                    self.exibirAnotacao(viagem: self.viagem )
                    
                }else{
                    print(erro!)
                }
                
            })
            
            
        }
        
    }
    
    
    func configuraGerenciadorLocalizacao(){
        
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedWhenInUse && status != .notDetermined {
            
            let alertaController = UIAlertController(title: "Permissão de localização",
                                                     message: "Necessário permissão para acesso à sua localização!! por favor habilite.",
                                                     preferredStyle: .alert )
            
            let acaoConfiguracoes = UIAlertAction(title: "Abrir configurações", style: .default , handler: { (alertaConfiguracoes) in
                
                if let configuracoes = NSURL(string: UIApplication.openSettingsURLString ) {
                    UIApplication.shared.open( configuracoes as URL )
                }
                
            })
            
            let acaoCancelar = UIAlertAction(title: "Cancelar", style: .default , handler: nil )
            
            alertaController.addAction( acaoConfiguracoes )
            alertaController.addAction( acaoCancelar )
            
            present( alertaController , animated: true, completion: nil )
            
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


