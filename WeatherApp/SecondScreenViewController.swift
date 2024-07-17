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
        
        
        
        let (symbol, color) = getWeatherSymbolAndColor(forCode: weatherData.current.condition.code,
                                                       isDay: weatherData.current.is_day)
        
        if let symbol = symbol, let color = color {
            let iconImage = UIImage(systemName: symbol)?.withTintColor(color, renderingMode: .alwaysOriginal)
           
            cell?.weatherConditionImg?.image = iconImage!
            
        } else {
            print("Weather symbol or color not found for code ")
        }
    
        
        return cell ?? UITableViewCell()
    }
}

extension SecondScreenViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
