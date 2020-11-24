
import UIKit
import QuartzCore

class IRIView: UIViewController, LineChartDelegate {
    var label = UILabel()
    var lineChart: LineChart!
    var data = [[[CGFloat]]]()

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(data: [[[CGFloat]]]) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        var views: [String: AnyObject] = [:]
        
        label.text = "IRI"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.center
        self.view.addSubview(label)
        views["label"] = label
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[label]", options: [], metrics: nil, views: views))
        
        let lineChart = getLineChart()
        self.view.addSubview(lineChart)
        views["chart"] = lineChart
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chart]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[chart(==200)]", options: [], metrics: nil, views: views))
    }
    
    func getLineChart() -> LineChart {
        
        
        // simple arrays
        //let data: [CGFloat] = [0.1, 4, 8, 10]
        //let data1: [[CGFloat]] = [[0.1, 0.2, 0.3, 33.0201, -127.9884], [0.1, 0.2, 0.3, 33.0201, -127.9884]]
        let data1 : [CGFloat] = [0.0, 6.0, 7.0, 0, 0]
        
        // simple line with custom x axis labels
        let xLabels: [String] = ["0", "1000", "2000", "3000", "4000", "5000"]
        
        lineChart = LineChart()
        lineChart.animation.enabled = true
        lineChart.area = true
        lineChart.x.labels.visible = true
        lineChart.x.grid.count = 1
        lineChart.y.grid.count = 2
        lineChart.x.labels.values = xLabels
        lineChart.y.labels.visible = true

        lineChart.addLine(data1)
        
      // for d in data1 {
      //  lineChart.addLine([data[0],data[1],data[2]])
     //   }
        
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        
        return lineChart
    }
        
        
        
        
//        var delta: Int64 = 4 * Int64(NSEC_PER_SEC)
//        var time = dispatch_time(DISPATCH_TIME_NOW, delta)
//        
//        dispatch_after(time, dispatch_get_main_queue(), {
//            self.lineChart.clear()
//            self.lineChart.addLine(data2)
//        });
        
//        var scale = LinearScale(domain: [0, 100], range: [0.0, 100.0])
//        var linear = scale.scale()
//        var invert = scale.invert()
//        println(linear(x: 2.5)) // 50
//        println(invert(x: 50)) // 2.5
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    /**
     * Line chart delegate method.
     */
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>) {
        label.text = "x: \(x)     y: \(yValues)"
    }
    
    
    
    /**
     * Redraw chart on device rotation.
     */
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if let chart = lineChart {
            chart.setNeedsDisplay()
        }
    }

}
