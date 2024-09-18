import UIKit

protocol FormSheetDelegate: AnyObject {
    func didUpdateTime(_ time: String)
}

class FormSheetViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Add total time:"
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.layer.cornerRadius = 19
        button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var hoursPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    private lazy var minutesPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    weak var delegate: FormSheetDelegate?
    private var selectedHour: Int = 0
    private var selectedMinute: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.addSubview(label)
        view.addSubview(stack)
        view.addSubview(saveButton)
        stack.addArrangedSubview(hoursPickerView)
        stack.addArrangedSubview(minutesPickerView)
        
        setupConstraints()
        setUIColor() // Apply color theme when the view loads
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserInterfaceStyleChange), name: .userInterfaceStyleChanged, object: nil)
    }

    @objc private func handleUserInterfaceStyleChange() {
        setUIColor()
    }
    
    func setUIColor() {
        let isDarkMode = UserDefaults.standard.string(forKey: "userInterfaceStyle") == "dark"
        
        if isDarkMode {
            hoursPickerView.setValue(UIColor(white: 1, alpha: 1), forKey: "textColor")
            minutesPickerView.setValue(UIColor(white: 1, alpha: 1), forKey: "textColor")
            label.textColor = .white
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.backgroundColor = UIColor(red: 0.1, green: 0.4, blue: 0.4, alpha: 1)
            view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        } else {
            label.textColor = .black
            hoursPickerView.setValue(UIColor(white: 0, alpha: 1), forKey: "textColor")
            minutesPickerView.setValue(UIColor(white: 0, alpha: 1), forKey: "textColor")
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.5, alpha: 1)
            view.backgroundColor = .white
        }
    }
    
    @objc func saveButtonAction() {
        let totalSeconds = (selectedHour * 3600) + (selectedMinute * 60)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        if let timeString = formatter.string(from: TimeInterval(totalSeconds)) {
            delegate?.didUpdateTime(timeString)
        }
        dismiss(animated: true)
    }
    
    private func setupConstraints() {
        label.snp.makeConstraints { make in
            make.top.equalTo(view).offset(20)
            make.leading.trailing.equalTo(view).inset(20)
        }
        
        stack.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view).inset(20)
            make.height.equalTo(150)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(10)
            make.centerX.equalTo(view)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == hoursPickerView {
            return 24
        } else {
            return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == hoursPickerView {
            return "\(row) hour(s)"
        } else {
            return "\(row) minute(s)"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == hoursPickerView {
            selectedHour = row
        } else {
            selectedMinute = row
        }
    }
}
