//
//  ContentView.swift
//  Shared
//
//  Created by Kuzey Demirkaya on 13.04.2022.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

struct Home : View {
    
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert = false
    @State var source : CLLocationCoordinate2D!
    @State var destination : CLLocationCoordinate2D!
    @State var name = ""
    @State var distance = ""
    @State var time = ""
    @State var show = false
    @State var loading = false
    @State var book = false
    @State var firstName = ""
    @State var lastName = ""
    @State var age = ""
    @State var university = ""
    @State var major = ""
    @State var unimail = ""
    @State var summary = false
    @State var imageSelected = UIImage()
    @State var search = false
    @State var selectedcolor1 = false
    @State var selectedcolor2 = false
    @State var selectedcolor3 = false
    @State var selectedcolor4 = false
    @State var confirmed = false
    @State var currentTime = Date()
    @State var departure = String()

    
    var body: some View{
        ZStack{
            ZStack(alignment: .bottom){
                VStack(spacing: 0){
                    HStack{
                        VStack(alignment: .leading, spacing: 15){
                            Text(self.destination != nil ? "İstikamet" : "Yolculuk Nereye")
                                .font(.title)
                            if self.destination != nil{
                                Text(self.name)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                        Button {
                            self.search.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
                    .background(Color.black)
                    MapView(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$source, destination: self.$destination, name: self.$name, distance: self.$distance, time: self.$time, show: self.$show)
                        .onAppear{
                            self.manager.requestAlwaysAuthorization()
                        }
                }
                if self.destination != nil && self.show{
                    ZStack(alignment: .topTrailing){
                        VStack{
                            HStack{
                                VStack(alignment: .leading, spacing: 15){
                                    Text("  İstikamet")
                                        .fontWeight(.bold)
                                    Text("    "+self.name)
                                    Text("    Mesafe: "+self.distance+" km")
                                    Text("    Zaman: "+self.time+" dk")
                                }
                                Spacer()
                            }
                            Button(action: {
                                self.Book()
                            }) {
                                Text("Pool")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .frame(width: UIScreen.main.bounds.width/3)
                            }
                            .background(Color.purple)
                            .clipShape(Capsule())
                        }
                        Button(action:{
                            self.map.removeOverlays(self.map.overlays)
                            self.map.removeAnnotations(self.map.annotations)
                            self.destination = nil
                            self.show.toggle()
                        }) {
                            Image(systemName: "xmark")
                                .frame(width: 25, height: 25)
                                .foregroundColor(.white)
                                .background(Color.gray)
                                .clipShape(Circle())
                            
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                    .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                    .background(Color.black)
                }
            }
            if self.book{
                Booked(firstName: self.$firstName, lastName: self.$lastName, age: self.$age, book: self.$book, loading: self.$loading, university: self.$university, major: self.$major, unimail: self.$unimail, summary: self.$summary)
            }
            if self.summary{
                Summary(firstName: self.$firstName, lastName: self.$lastName, age: self.$age, university: self.$university, major: self.$major, unimail: self.$unimail, imageSelected: self.$imageSelected, summary: self.$summary, distance: self.$distance, book: self.$book, selectedcolor1: self.$selectedcolor1, selectedcolor2: self.$selectedcolor2, selectedcolor3: self.$selectedcolor3, selectedcolor4: self.$selectedcolor4, confirmed: self.$confirmed, departure: self.$departure)
            }
            if self.search{
                SearchView(show: self.$search, map: self.$map, source: self.$source, destination: self.$destination, name: self.$name, distance: self.$distance, time: self.$time,detail: self.$show)
            }
            if self.confirmed{
                Confirmed(confirmed: self.$confirmed, selectedcolor1: self.$selectedcolor1, selectedcolor2: self.$selectedcolor2, selectedcolor3: self.$selectedcolor3, selectedcolor4: self.$selectedcolor4, name: self.$name, distance: self.$distance, time: self.$time, book: self.$book, summary: self.$summary, departure: self.$departure)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: self.$alert) { () -> Alert in
            Alert(title: Text("Uyarı"), message: Text("Konum erişimine izin ver"), dismissButton: .destructive(Text("Tamam")))
        }
    }
    func Book(){
        self.book.toggle()
        }
}

struct Loader : View{
    @State var show = false
    var body: some View{
        GeometryReader{geometry in
            VStack(spacing: 20){
                Circle()
                    .trim(from: 0.0, to: 0.7)
                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 30, height: 30)
                    .rotationEffect(.init(degrees: self.show ? 360 : 0))
                    .onAppear{
                        withAnimation(Animation.default.speed(0.45).repeatForever(autoreverses: false)){
                            self.show.toggle()
                        }
                    }
                Text("Loading ...")
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 50)
            .background(Color.white.opacity(0.90))
            .cornerRadius(12)
            .frame(width: geometry.size.width * 1, height: geometry.size.height*1)
        }
        .background(Color.black.opacity(0.25).edgesIgnoringSafeArea(.all))
    }
}

struct MapView : UIViewRepresentable{
    
    func makeCoordinator() -> Coordinator {
        return MapView.Coordinator(parent1: self)
    }
    
    
    @Binding var map : MKMapView
    @Binding var manager : CLLocationManager
    @Binding var alert : Bool
    @Binding var source : CLLocationCoordinate2D!
    @Binding var destination : CLLocationCoordinate2D!
    @Binding var name : String
    @Binding var distance : String
    @Binding var time : String
    @Binding var show : Bool
    
    func makeUIView(context: Context) -> MKMapView {
        map.delegate = context.coordinator
        manager.delegate = context.coordinator
        map.showsUserLocation = true
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.tap(ges:)))
        map.addGestureRecognizer(gesture)
        return map
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    class Coordinator: NSObject,MKMapViewDelegate,CLLocationManagerDelegate{
        var parent : MapView
        init(parent1: MapView){
            parent = parent1
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .denied{
                self.parent.alert.toggle()
            }
            else{
                self.parent.manager.startUpdatingLocation()
            }
        }
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let region = MKCoordinateRegion(center: locations.last!.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            self.parent.source = locations.last!.coordinate
            self.parent.map.region = region
        }
        @objc func tap(ges: UITapGestureRecognizer){
            let location = ges.location(in: self.parent.map)
            let maplocation = self.parent.map.convert(location, toCoordinateFrom: self.parent.map)
            let point = MKPointAnnotation()
            point.title = ""
            point.subtitle = ""
            point.coordinate = maplocation
            self.parent.destination = maplocation
            let decoder = CLGeocoder()
            decoder.reverseGeocodeLocation(CLLocation(latitude: maplocation.latitude, longitude: maplocation.longitude)){ (places, err) in
                if err != nil{
                    //print((err?.localizedDescription)!)
                    return
                }
                self.parent.name = places?.first?.name ?? ""
                point.title = places?.first?.name ?? ""
                self.parent.show = true
            }
            let req = MKDirections.Request()
            req.source = MKMapItem(placemark: MKPlacemark(coordinate: self.parent.source))
            req.destination = MKMapItem(placemark: MKPlacemark(coordinate: maplocation))
            let directions = MKDirections(request: req)
            directions.calculate{(dir, err) in
                if err != nil{
                    //print((err?.localizedDescription)!)
                    return
                }
                let polyline = dir?.routes[0].polyline
                let dis = dir?.routes[0].distance as! Double
                self.parent.distance = String(format: "%.1f", dis/1000)
                let time = dir?.routes[0].expectedTravelTime as! Double
                self.parent.time = String(format: "%.1f", time/60)
                self.parent.map.removeOverlays(self.parent.map.overlays)
                self.parent.map.addOverlay(polyline!)
                self.parent.map.setRegion(MKCoordinateRegion(polyline!.boundingMapRect), animated: true)
            }
            self.parent.map.removeAnnotations(self.parent.map.annotations)
            self.parent.map.addAnnotation(point)
        }
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let over = MKPolylineRenderer(overlay: overlay)
            over.strokeColor = .purple
            over.lineWidth = 3
            return over
        }
    }
}

struct Booked : View{
    @Binding var firstName : String
    @Binding var lastName : String
    @Binding var age : String
    @Binding var book : Bool
    @Binding var loading : Bool
    @Binding var university : String
    @Binding var major : String
    @Binding var unimail : String
    @State var changeProfileImage = false
    @State var openCameraRoll = false
    @State var imageSelected = UIImage()
    @Binding var summary : Bool
    
    var body: some View{
        NavigationView{
            VStack{
                HStack{
                    Text("Yolcu Bilgileri")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action:{
                        self.book.toggle()
                    }) {
                        Image(systemName: "xmark")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .background(Color.gray)
                            .clipShape(Circle())
                    }
                }
                Spacer()
                ZStack(alignment: .bottomTrailing) {
                    Button {
                        changeProfileImage = true
                        openCameraRoll = true
                    } label: {
                        if changeProfileImage {
                            Image(uiImage: imageSelected)
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                    }
                        else{
                            Image("profileImage")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        }
                    }
                    Image(systemName: "plus")
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Circle())
                }.sheet(isPresented: $openCameraRoll) {
                    ImagePicker(selectedImage: $imageSelected, sourceType: .photoLibrary)
                }
                Form{
                    Section{
                        TextField("İsim", text: self.$firstName)
                        TextField("Soyisim", text: self.$lastName)
                    }
                    Section{
                        TextField("Yaş", text: self.$age).keyboardType(.numberPad)
                    }
                    Section{
                        TextField("Üniversite", text: self.$university)
                        TextField("Bölüm", text: self.$major)
                    }
                    Section{
                        TextField("Öğrenci Mail", text: self.$unimail)
                    }
                }
                if !firstName.isEmpty && !lastName.isEmpty && !age.isEmpty && !university.isEmpty && !major.isEmpty && unimail.contains("edu.tr"){
                    Button{
                        self.summary.toggle()
                    } label: {
                        Text("Devam")
                            .frame(width: 200, height: 50, alignment: .center)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .padding(25)
                }
                else{
                    Text("Devam")
                        .frame(width: 200, height: 50, alignment: .center)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    
                }
            }
            .padding()
            .background(Color.black)
        }
    }
}

struct Summary : View{
    @Binding var firstName : String
    @Binding var lastName : String
    @Binding var age : String
    @Binding var university : String
    @Binding var major : String
    @Binding var unimail : String
    @Binding var imageSelected : UIImage
    @Binding var summary : Bool
    @Binding var distance : String
    @Binding var book : Bool
    @Binding var selectedcolor1 : Bool
    @Binding var selectedcolor2 : Bool
    @Binding var selectedcolor3 : Bool
    @Binding var selectedcolor4 : Bool
    @Binding var confirmed : Bool
    @Binding var departure : String
    var body: some View{
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                HStack{
                    Text("Yolculuk")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action:{
                        self.book.toggle()
                        self.summary.toggle()
                    }) {
                        Image(systemName: "xmark")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .background(Color.gray)
                            .clipShape(Circle())
                    }
                }
                let price = (self.distance as NSString).floatValue * 1.2
                Spacer()
                //Image(uiImage: self.imageSelected)
                //    .resizable()
                //    .frame(width: 120, height: 120)
                //    .clipShape(Circle())
                Group{
                    Text("Yolcu:  "+self.firstName+" "+self.lastName)
                    Text("Yaş:  "+self.age)
                    Text("Üniversite:  "+self.university)
                    Text("Bölüm:  "+self.major)
                    Text("Mail:  "+self.unimail)
                }
                Spacer()
                TextField("Kalkış Saati", text: self.$departure)
                Spacer()
                Group{
                    HStack{
                        Button {
                            self.selectedcolor1.toggle()
                            if self.selectedcolor2 == true{
                                self.selectedcolor2.toggle()
                            }
                            if self.selectedcolor3 == true{
                                self.selectedcolor3.toggle()
                            }
                            if self.selectedcolor4 == true{
                                self.selectedcolor4.toggle()
                            }
                        } label: {
                            VStack{
                                Text("1 Yolcu")
                                    .fontWeight(.bold)
                                Text(String(format: "%.1f", price)+" ₺")
                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 10)
                        }
                        .background(self.selectedcolor1 ? Color.blue : Color.black)
                        .cornerRadius(6)
                        .foregroundColor(.white)
                        Spacer()
                        Button {
                            self.selectedcolor2.toggle()
                            if self.selectedcolor1 == true{
                                self.selectedcolor1.toggle()
                            }
                            if self.selectedcolor3 == true{
                                self.selectedcolor3.toggle()
                            }
                            if self.selectedcolor4 == true{
                                self.selectedcolor4.toggle()
                            }
                        } label: {
                            VStack{
                                Text("2 Yolcu")
                                    .fontWeight(.bold)
                                Text(String(format: "%.1f", price/2)+" ₺")
                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 10)
                        }
                        .background(self.selectedcolor2 ? Color.blue : Color.black)
                        .cornerRadius(6)
                        .foregroundColor(.white)
                        Spacer()
                        Button {
                            self.selectedcolor3.toggle()
                            if self.selectedcolor2 == true{
                                self.selectedcolor2.toggle()
                            }
                            if self.selectedcolor1 == true{
                                self.selectedcolor1.toggle()
                            }
                            if self.selectedcolor4 == true{
                                self.selectedcolor4.toggle()
                            }
                        } label: {
                            VStack{
                                Text("3 Yolcu")
                                    .fontWeight(.bold)
                                Text(String(format: "%.1f", price/3)+" ₺")
                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 10)
                        }
                        .background(self.selectedcolor3 ? Color.blue : Color.black)
                        .cornerRadius(6)
                        .foregroundColor(.white)
                        Spacer()
                        Button {
                            self.selectedcolor4.toggle()
                            if self.selectedcolor2 == true{
                                self.selectedcolor2.toggle()
                            }
                            if self.selectedcolor3 == true{
                                self.selectedcolor3.toggle()
                            }
                            if self.selectedcolor1 == true{
                                self.selectedcolor1.toggle()
                            }
                        } label: {
                            VStack{
                                Text("4 Yolcu")
                                    .fontWeight(.bold)
                                Text(String(format: "%.1f", price/4)+" ₺")
                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 10)
                        }
                        .background(self.selectedcolor4 ? Color.blue : Color.black)
                        .cornerRadius(6)
                        .foregroundColor(.white)
                    }
                }
                Group{
                    Spacer()
                    if self.selectedcolor1 == true || self.selectedcolor2 == true || self.selectedcolor3 == true || self.selectedcolor4 == true{
                        Button{
                            self.confirmed.toggle()
                        } label: {
                            Text("Onayla")
                                .frame(width: 200, height: 50, alignment: .center)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .padding(25)
                    }
                    else{
                        Text("Onayla")
                            .frame(width: 200, height: 50, alignment: .center)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .frame(
                width: geo.size.width,
                height: geo.size.height,
                alignment: .topLeading)
        }
        .background(Color.black)
    }
}

struct Confirmed : View{
    @Binding var confirmed : Bool
    @Binding var selectedcolor1 : Bool
    @Binding var selectedcolor2 : Bool
    @Binding var selectedcolor3 : Bool
    @Binding var selectedcolor4 : Bool
    @Binding var name : String
    @Binding var distance : String
    @Binding var time : String
    @Binding var book : Bool
    @Binding var summary : Bool
    @Binding var departure : String
    var body: some View{
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                HStack{
                    Button(action:{
                        self.confirmed.toggle()
                        self.summary.toggle()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                Spacer()
                HStack{
                    Text("Yolculuğunuz Onaylandı")
                        .font(.title)
                        .fontWeight(.bold)
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Spacer()
                    Button(action:{
                        self.book.toggle()
                        self.summary.toggle()
                        self.confirmed.toggle()
                    }) {
                        Image(systemName: "xmark")
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .background(Color.gray)
                            .clipShape(Circle())
                    }
                }
                Spacer()
                let price = (self.distance as NSString).floatValue * 1.2
                Group{
                if self.selectedcolor1 == true{
                    Text("1 yolcu")
                        .fontWeight(.bold)
                    Text("Ücret:  "+String(format: "%.1f", price)+" ₺")
                        .fontWeight(.bold)
                }
                if self.selectedcolor2 == true{
                    Text("2 yolcu")
                        .fontWeight(.bold)
                    Text("Ücret:  "+String(format: "%.1f", price/2)+" ₺")
                        .fontWeight(.bold)
                }
                if self.selectedcolor3 == true{
                    Text("3 yolcu")
                        .fontWeight(.bold)
                    Text("Ücret:  "+String(format: "%.1f", price/3)+" ₺")
                        .fontWeight(.bold)
                }
                if self.selectedcolor4 == true{
                    Text("4 yolcu")
                        .fontWeight(.bold)
                    Text("Ücret:  "+String(format: "%.1f", price/4)+" ₺")
                        .fontWeight(.bold)
                }
                }
                Spacer()
                Group{
                Text("    İstikamet: "+self.name)
                Text("    Mesafe: "+self.distance+" km")
                Text("    Zaman: "+self.time+" dk")
                Text("    Kalkış Saati: "+self.departure)
                }
                Spacer()
            }
            .padding(.horizontal, 50)
            .frame(
                width: geo.size.width,
                height: geo.size.height,
                alignment: .topLeading)
        }
        .background(Color.black)
    }
}
