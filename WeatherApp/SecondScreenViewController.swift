import UIKit

class SecondScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var citiesWeather: [weatherDataObject] = [] 
    var isCelsius: Bool = true
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let weatherData = citiesWeather[indexPath.row]
        
        let temperature = isCelsius ? weatherData.current.temp_c : weatherData.current.temp_f 
        let unit = isCelsius ? "C" : "F"
        
        cell.textLabel?.text = "\(weatherData.location.name) - \(temperature)°\(unit)"
        
        var iconURLString = weatherData.current.condition.icon
        if !iconURLString.hasPrefix("http://") && !iconURLString.hasPrefix("https://") {
            iconURLString = "https:" + iconURLString
        }
        
        // Load image asynchronously
        if let imageURL = URL(string: iconURLString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        cell.imageView?.image = image
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        
        return cell
    }
}
