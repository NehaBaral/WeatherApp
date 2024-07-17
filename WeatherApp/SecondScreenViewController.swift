import UIKit

class SecondScreenViewController: UIViewController {
    
    var citiesWeather: [weatherModel] = [] 
    var isCelsius: Bool = true
    let cellSpacingHeight: CGFloat = 140
    
    @IBOutlet weak var emptyData: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyData.isHidden = citiesWeather.isEmpty == false
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.layer.cornerRadius = 10.0
    }
    
    
}

extension SecondScreenViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesWeather.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCellIdentifier", for: indexPath) as? SecondScreenTableViewCell
        
        let weatherData = citiesWeather[indexPath.row]
        let temperature = isCelsius ? weatherData.current.temp_c : weatherData.current.temp_f
        let unit = isCelsius ? "C" : "F"
        cell?.titleView.text = "\(weatherData.location.name) - \(temperature)°\(unit)"
        
        cell?.descView.text = "\(weatherData.current.condition.text)"
        
        
        
        let (symbol, color1, color2) = getWeatherSymbolAndColor(forCode: weatherData.current.condition.code,
                                                       isDay: weatherData.current.is_day)
        
        if let symbol = symbol, let color1 = color1, let color2 = color2 {
            let iconImage = UIImage(systemName: symbol)
            let config = UIImage.SymbolConfiguration(paletteColors: [color1,color2])
            cell?.weatherConditionImg.preferredSymbolConfiguration = config
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
