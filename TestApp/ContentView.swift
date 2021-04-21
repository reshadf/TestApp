//
//  ContentView.swift
//  TestApp
//
//  Created by Reshad Farid on 21/04/2021.
//

import SwiftUI

struct ListOfMemes: View {
    
    @State private var memeImages: [String] = []
    
    let columns = [
        GridItem(.flexible(minimum: 100), spacing: 4),
        GridItem(.flexible(minimum: 100), spacing: 4),
        GridItem(.flexible(minimum: 100), spacing: 4),
    ]
    
    fileprivate func memePreview(_ meme: String) -> some View {
        return Image(uiImage: UIImage(named: meme)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100, alignment: .center)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                NavigationLink(
                    destination: MemeEditorView(),
                    label: {
                        Label("Create your own meme", systemImage: "camera")
                            .padding([.leading, .bottom])
                        Spacer()
                    })
                
                HStack {
                    Text("Use one of these memes")
                    Spacer()
                }
                .padding(.leading)
                    
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(memeImages, id: \.self) { meme in
                        NavigationLink(
                            destination: MemeEditorView(customImage: meme),
                            label: {
                                memePreview(meme)
                            })
                    }
                }
            }
            .padding(.top)

            .navigationBarTitle("Meme generator", displayMode: .automatic)
            .onAppear(perform: {
                memeImages = listOfMemesFromDirectory()
            })
        }
    }
    
    func listOfMemesFromDirectory() -> [String] {
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fileManager.contentsOfDirectory(atPath: path)
        
        return items.filter { $0.hasPrefix("meme") }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListOfMemes()
    }
}

struct MemeEditorView: View {
    
    @State var topText: String = ""
    
    @State var bottomText: String = ""
    
    @State var memeImage: Image?
    
    @State var fontSize: Float = 20
    
    @State var imageSize: CGSize = .zero
    
    @State private var fontColor = Color.white
    
    @State private var inputImage: UIImage?
    
    @State private var showingChooseText = false
    
    init() {}
    
    init(customImage image: String) {
        _inputImage = State(initialValue: UIImage(named: image))
        guard let inputImage = inputImage else { return }
        _memeImage = State(initialValue: Image(uiImage: inputImage))
        _imageSize = State(initialValue: inputImage.size)
    }
    
    var memeView: some View {
        MemeView(topText: $topText, bottomText: $bottomText, memeImage: $memeImage, fontColor: $fontColor, fontSize: $fontSize, imageSize: $imageSize)
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        memeImage = Image(uiImage: inputImage)
        let width = inputImage.size.width
        let height = inputImage.size.height
        
        var finalWidth: CGFloat = 0
        var finalHeight: CGFloat = 0
        
        DispatchQueue.main.async {
            if width > height {
                // Landscape image
                // Use screen width if < than image width
                finalWidth = width > UIScreen.main.bounds.width ? UIScreen.main.bounds.width : width
                // Scale height
                finalHeight = finalWidth/width * height
            } else {
                // Portrait
                // Use 600 if image height > 600
                finalHeight = height > 600 ? 600 : height
                // Scale width
                finalWidth = finalHeight/height * width
            }
            imageSize = CGSize(width: finalWidth, height: finalHeight)
        }
    }
    
    func shrinkImage(_ inputImage: UIImage) {
        let width = inputImage.size.width
        let height = inputImage.size.height
        
        var finalWidth: CGFloat = 0
        var finalHeight: CGFloat = 0
        
        DispatchQueue.main.async {
            if width > height {
                // Landscape image
                // Use screen width if < than image width
                finalWidth = width > UIScreen.main.bounds.width ? UIScreen.main.bounds.width : width
                // Scale height
                finalHeight = finalWidth/width * height
            } else {
                // Portrait
                // Use 600 if image height > 600
                finalHeight = height > 600 ? 600 : height
                // Scale width
                finalWidth = finalHeight/height * width
            }
            imageSize = CGSize(width: finalWidth, height: finalHeight)
        }
    }
    
    var body: some View {
        
        NavigationView {
            
            memeView
                .onAppear(perform: {
                    if let image = inputImage {
                        shrinkImage(image)
                    }
                })
                .navigationBarTitle("Meme canvas", displayMode: .inline)
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        
                        Spacer()
                        
                        Button(action: {
                            showingChooseText = true
                        }, label: {
                            Image(systemName: "pencil.tip")
                        })
                        .sheet(isPresented: $showingChooseText) {
                            MemeTextEditorView(memeImage: $memeImage, fontColor: $fontColor, topText: $topText, bottomText: $bottomText, fontSize: $fontSize, showingChooseText: $showingChooseText, imageSize: $imageSize)
                        }
                        
                        Spacer()
                    }
                }
                .navigationBarHidden(true)
        }
    }
}

struct MemeTextEditorView: View {
    
    @Binding var memeImage: Image?
    @Binding var fontColor: Color
    @Binding var topText: String
    @Binding var bottomText: String
    @Binding var fontSize: Float
    @Binding var showingChooseText: Bool
    @Binding var imageSize: CGSize
    
    var topTextView: some View {
        TextField("Enter your top text", text: $topText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    var bottomTextView: some View {
        TextField("Enter your bottom text", text: $bottomText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Enter your meme text")
                .font(.title)
                .bold()
            
            Text("Preview")
                .padding(.top)
            
            MemeView(topText: $topText, bottomText: $bottomText, memeImage: $memeImage, fontColor: $fontColor, fontSize: $fontSize, imageSize: $imageSize)
            
            Group {
                topTextView
                bottomTextView
            }
            .padding([.top, .bottom])
            
            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    showingChooseText = false
                }, label: {
                    Text("Done")
                })
                Spacer()
            }
        }
        .padding()
    }
}

struct MemeView: View {
    
    @Binding var topText: String
    @Binding var bottomText: String
    @Binding var memeImage: Image?
    @Binding var fontColor: Color
    @Binding var fontSize: Float
    @Binding var imageSize: CGSize
    
    var body: some View {
        
        if let image = memeImage {
            
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
                .overlay(
                    VStack {
                        Text(topText)
                            .font(.system(size: CGFloat(fontSize)))
                            .bold()
                            .foregroundColor(fontColor)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black, radius: 1)

                        Spacer()

                        Text(bottomText)
                            .font(.system(size: CGFloat(fontSize)))
                            .bold()
                            .foregroundColor(fontColor)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black, radius: 1)
                    }
                    .padding()
            )
            
        } else {
            Text("Tap the + button and upload your meme")
        }
    }
}
