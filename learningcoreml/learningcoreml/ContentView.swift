//
//  ContentView.swift
//  learningcoreml
//
//  Created by Nigel Tan Yong on 24/1/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var predictionText: String = "Predicted digit: ?"
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage?

    private let modelManager = MyModel()

    var body: some View {
        VStack {
            Button("Select Image") {
                isImagePickerPresented.toggle()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }
            .padding()

            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .padding()

                Text(predictionText)
                    .padding()
                    .foregroundColor(.black)
            }
        }
        .onChange(of: selectedImage) { newImage in
                    // Call the predict method with the selected image
            if let prediction = modelManager.predict(image: (newImage?.cgImage)!) {
                        // Handle the prediction (e.g., update UI)
                        print("Predicted digit: \(prediction)")
                        predictionText = "Predicted digit: \(prediction)"
                    }
                }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var image: UIImage?

        init(image: Binding<UIImage?>) {
            _image = image
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                image = uiImage
            }

            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(image: $image)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

