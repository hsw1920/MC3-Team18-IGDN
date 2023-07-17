//
//  CreateMapViewController.swift
//  Pluto
//
//  Created by 홍승완 on 2023/07/11.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import UIKit
import Combine

class CreateMapViewController: UIViewController {

    private let input = PassthroughSubject<CreateMapViewModel.Input, Never>()
    private let inputToParent = PassthroughSubject<CreateModeViewModel.Input, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    private var contentView = CreateMapView()
    
    var viewModel: CreateMapViewModel!
    var parentViewModel: CreateModeViewModel!
    
    override func loadView() {
        view = contentView
    }
    
    init(_ createModeViewModel: CreateModeViewModel, _ viewModel: CreateMapViewModel) {
        self.parentViewModel = createModeViewModel
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setUpTargets()
        setUpGestureRecognizer()
        setUpEditModeView()
        showContentView(isShown: true)
        self.contentView.scrollView.delegate = self
        self.contentView.nameInputView.nameTextField.delegate = self
    }
    
    private func setUpGestureRecognizer() {
        let addObjectTapGesture = UITapGestureRecognizer(target: self, action: #selector(addObjectByTap(_:)))
        self.contentView.scrollView.addGestureRecognizer(addObjectTapGesture)
        self.contentView.scrollView.isUserInteractionEnabled = true
        
        let hideKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardByTap))
        contentView.nameInputView.addGestureRecognizer(hideKeyboardTapGesture)
    }
    
    private func setUpTargets() {
        contentView.bottomToolView.objectUpButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        contentView.bottomToolView.objectDownButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        contentView.bottomToolView.objectColorUpButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        contentView.bottomToolView.objectColorDownButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        contentView.bottomToolView.objectSizeUpButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        contentView.bottomToolView.objectSizeDownButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        contentView.topToolView.backButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        contentView.topToolView.saveButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        contentView.alertView.keepEditingButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        contentView.alertView.discardButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        contentView.nameInputView.backButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        contentView.nameInputView.saveButton.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
    }

    private func setUpEditModeView() {
        if viewModel.isEditing {
            viewModel.creativeObjectList?.forEach{
                addObjectScrollView(with: $0.object)
            }
        }
    }
    
    private func bind(){
        
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.receive(on: RunLoop.main)
            .sink { [weak self] event in
                switch event {
                case .objectUpButtonDidTapOutput:
                    print(">>> receive: objectUpButtonDidTapOutput")
                    self?.contentView.bottomToolView.objectView.backgroundColor = self?.viewModel.object
                case .objectDownButtonDidTapOutput:
                    print(">>> receive: objectDownButtonDidTapOutput")
                    self?.contentView.bottomToolView.objectView.backgroundColor = self?.viewModel.object
                case .objectSizeUpButtonDidTapOutput:
                    print(">>> receive: objectSizeUpButtonDidTapOutput")
                    self?.contentView.bottomToolView.objectSizeView.backgroundColor = self?.viewModel.objectSize
                case .objectSizeDownButtonDidTapOutput:
                    print(">>> receive: objectSizeDownButtonDidTapOutput")
                    self?.contentView.bottomToolView.objectSizeView.backgroundColor = self?.viewModel.objectSize
                case .objectColorUpButtonDidTapOutput:
                    print(">>> receive: objectColorUpButtonDidTapOutput")
                    self?.contentView.bottomToolView.objectColorView.backgroundColor = self?.viewModel.objectColor
                case .objectColorDownButtonDidTapOutput:
                    print(">>> receive: objectColorDownButtonDidTapOutput")
                    self?.contentView.bottomToolView.objectColorView.backgroundColor = self?.viewModel.objectColor
                case .saveButtonDidTapOutput:
                    print(">>> receive: saveButtonDidTapOutput")
                    self?.navigationController?.popViewController(animated: true)
                    print("saveButton Did Tap")
                }
            }.store(in: &subscriptions)
        
    }
    
    @objc private func buttonDidTap(_ sender: UIButton) {
        switch sender {
        case self.contentView.bottomToolView.objectUpButton:
            viewModel.updateObject(isIncrease: true)
            input.send(.objectUpButtonDidTap)
        case self.contentView.bottomToolView.objectDownButton:
            viewModel.updateObject(isIncrease: false)
            input.send(.objectDownButtonDidTap)
        case self.contentView.bottomToolView.objectSizeUpButton:
            viewModel.updateObjectSize(isIncrease: true)
            input.send(.objectSizeUpButtonDidTap)
        case self.contentView.bottomToolView.objectSizeDownButton:
            viewModel.updateObjectSize(isIncrease: false)
            input.send(.objectSizeDownButtonDidTap)
        case self.contentView.bottomToolView.objectColorUpButton:
            viewModel.updateObjectColor(isIncrease: true)
            input.send(.objectColorUpButtonDidTap)
        case self.contentView.bottomToolView.objectColorDownButton:
            viewModel.updateObjectColor(isIncrease: false)
            input.send(.objectColorDownButtonDidTap)
        case self.contentView.topToolView.backButton:
            if viewModel.isChangedCreativeObjectList() {
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlertView(isShown: true)
            }
        case self.contentView.topToolView.saveButton:
            if viewModel.isEditing {
                input.send(.saveButtonDidTap)
            } else {
                showNameInputView(isShown: true)
            }
        case self.contentView.alertView.keepEditingButton:
            showContentView(isShown: true)
        case self.contentView.alertView.discardButton:
            self.navigationController?.popViewController(animated: true)
        case self.contentView.nameInputView.backButton:
            contentView.nameInputView.nameTextField.resignFirstResponder()
            showContentView(isShown: true)
        case self.contentView.nameInputView.saveButton:
            if self.contentView.nameInputView.nameTextField.text?.count == 0 {
                viewModel.map?.titleLabel  = ""
            } else {
                viewModel.map?.titleLabel = self.contentView.nameInputView.nameTextField.text!
            }
            input.send(.saveButtonDidTap)
        default:
            fatalError()
        }
    }
    
    func configure(_ createModeViewModel: CreateModeViewModel, _ viewModel: CreateMapViewModel) {
        self.parentViewModel = createModeViewModel
        self.viewModel = viewModel
    }

    private func showContentView(isShown: Bool){
        if isShown {
            [contentView.topToolView, contentView.bottomToolView, contentView.scrollView].forEach {
                $0.isHidden = !isShown
            }
            [contentView.alertView, contentView.nameInputView].forEach {
                $0.isHidden = isShown
            }
        }
    }
    
    private func showAlertView(isShown: Bool){
        if isShown {
            [contentView.alertView].forEach {
                $0.isHidden = !isShown
            }
            [contentView.topToolView, contentView.bottomToolView, contentView.scrollView, contentView.nameInputView].forEach {
                $0.isHidden = isShown
            }
        }
    }
    
    private func showNameInputView(isShown: Bool){
        if isShown {
            [contentView.nameInputView].forEach {
                $0.isHidden = !isShown
            }
            [contentView.topToolView, contentView.bottomToolView, contentView.scrollView, contentView.alertView].forEach {
                $0.isHidden = isShown
            }
        }
    }
}

extension CreateMapViewController: UIScrollViewDelegate {
    // UITapGestureRecognizer의 액션 메서드
    @objc func addObjectByTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.contentView.scrollView)
        let offset = self.contentView.scrollView.contentOffset
        let tappedPoint = CGPoint(x: tapLocation.x + offset.x, y: tapLocation.y + offset.y)
        if viewModel.addObjectAtPoint(tappedPoint, tapLocation) {
            addObjectScrollView(with: (viewModel.creativeObjectList?.last!.object)!)
        }
    }
    
    func addObjectScrollView(with objectView: UIView) {
        self.contentView.scrollView.addSubview(objectView)
    }

}

extension CreateMapViewController: UITextFieldDelegate {
    @objc private func hideKeyboardByTap() {
        if contentView.nameInputView.nameTextField.isFirstResponder {
            contentView.nameInputView.nameTextField.resignFirstResponder()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
