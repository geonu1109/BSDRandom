//
//  ViewController.swift
//  BSDRandom
//
//  Created by 전건우 on 05/05/2019.
//  Copyright © 2019 geonu. All rights reserved.
//

import UIKit
import ReSwift
import RxSwift
import RxCocoa
import MessageUI

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, StoreSubscriber, MFMessageComposeViewControllerDelegate {
    @IBOutlet private var selectAllUsersButton: UIButton!
    @IBOutlet private var countLabel: UILabel!
    @IBOutlet private var confirmButton: UIButton!
    @IBOutlet private var messageTextField: UITextField!
    @IBOutlet private var targetCountLabel: UILabel!
    @IBOutlet private var targetStepper: UIStepper!
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    private var state: AppState? = nil {
        didSet {
            selectAllUsersButton.setTitle(state?.selectedAllUsers ?? false == true ? "전체 해제" : "전체 선택", for: .normal)
            countLabel.text = "\(state?.selectedUsersCount ?? 0)명 중 \(state?.targetCount ?? 0)명"
            confirmButton.isEnabled = state?.targetCount ?? 0 > 0
            targetCountLabel.text = "\(state?.targetCount ?? 0)명"
            targetStepper.maximumValue = Double(state?.selectedUsersCount ?? 0)
            
            tableView.reloadData()
        }
    }
    private var disposables: [Disposable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unbind()
    }
    
    @IBAction private func tapped() {
        view.endEditing(true)
    }
    
    private func bind() {
        Redux.shared.store.subscribe(self)
        disposables.append(selectAllUsersButton.rx.tap.bind {
            UISelectionFeedbackGenerator().selectionChanged()
            Redux.shared.store.dispatch(AppAction.selectOrDeselectAllUsers)
        })
        disposables.append(confirmButton.rx.tap.bind {
            guard let state = self.state else {
                return
            }
            if MFMessageComposeViewController.canSendText() {
                let vc = MFMessageComposeViewController()
                vc.messageComposeDelegate = self
                let randoms = Int.randoms(lessThan: state.selectedUsersCount, number: state.targetCount)
                vc.recipients = randoms.map { state.selectedUsers[$0].phoneNumber }
                vc.body = state.message
                UINotificationFeedbackGenerator.init().notificationOccurred(.success)
                self.present(vc, animated: true, completion: nil)
            }
        })
        disposables.append(messageTextField.rx.controlEvent(.editingChanged).bind {
            UISelectionFeedbackGenerator().selectionChanged()
            Redux.shared.store.dispatch(AppAction.setMessage(value: self.messageTextField.text ?? ""))
        })
        disposables.append(targetStepper.rx.controlEvent(.valueChanged).bind {
            UISelectionFeedbackGenerator().selectionChanged()
            Redux.shared.store.dispatch(AppAction.setTargerCount(value: Int(self.targetStepper.value)))
        })
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unbind() {
        Redux.shared.store.unsubscribe(self)
        disposables.forEach { $0.dispose() }
        disposables = []
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func newState(state: AppState) {
        self.state = state
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return
        }
        tableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        tableView.contentInset = .init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }
    
    @objc private func keyboardWillHide() {
        tableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state?.users.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let state = state else {
            return tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        }
        let index = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        cell.setup(user: state.users[index], index: index)
        return cell
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

