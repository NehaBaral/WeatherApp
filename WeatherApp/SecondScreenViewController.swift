import UIKit

class SecondScreenViewController: UIViewController {
    
    var citiesWeather: [weatherModel] = [] 
    var isCelsius: Bool = true
    
    @IBOutlet weak var emptyData: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyData.isHidden = citiesWeather.isEmpty == false
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
}

extension SecondScreenViewController : UITableViewDataSource{
    //Indicate number of items in the list
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCellIdentifier", for: indexPath) as? SecondScreenTableViewCell
        
        let weatherData = citiesWeather[indexPath.row]
        let temperature = isCelsius ? weatherData.current.temp_c : weatherData.current.temp_f
        let unit = isCelsius ? "C" : "F"
        cell?.titleView.text = "\(weatherData.location.name) - \(temperature)°\(unit)"
        
        cell?.descView.text = "\(weatherData.current.condition.text)"
        
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
                        cell?.weatherConditionImg?.image = image
                    }
                }
            }
        }
        
        return cell ?? UITableViewCell()
    }
}

extension SecondScreenViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
