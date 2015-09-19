//
//  IAPHelperX.swift
//  PaddleBallA52
//
//  Created by iMac 27 on 2015-09-14.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

//import Foundation
//import StoreKit
//
//class IAPHelperX: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
//    
//    let productIdentifiers: NSSet
//    override init() {
//        productIdentifiers = NSSet(objects: "com.garthmackenzie.PaddleBallA52.addCredits.10", "com.garthmackenzie.PaddleBallA52.addCredits.40", "com.garthmackenzie.PaddleBallA52.addCredits.70", "com.garthmackenzie.PaddleBallA52.addCredits.150", "com.garthmackenzie.PaddleBallA52.addCredits.350", "com.garthmackenzie.PaddleBallA52.addCredits.1000", "com.garthmackenzie.PaddleBallA52.addCredits.2500")
//    }
//    func requestProductsWithCompletionHandler(completionHandler:(Bool, [SKProduct]!) -> Void){
//        self.completionHandler = completionHandler
//        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
//        productsRequest.delegate = self
//        productsRequest.start()
//    }
//    var completionHandler: ((Bool, [SKProduct]!) -> Void)!
//    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
//        print("product count \(response.products.count)")
//        print("invalid product IDs \(response.invalidProductIdentifiers)")
//        if response.products.count > 0 {
//            var products: [SKProduct] = []
//            for prod in response.products {
//                if prod.isKindOfClass(SKProduct) {
//                    products.append(prod )
//                }
//            }
//            completionHandler(true, products)
//        }
//    }
//    func request(request: SKRequest, didFailWithError error: NSError) {
//        print("please enable IAPS")
//        completionHandler(false, nil)
//    }
//    func pay4Credits(credits: Int) {
//        for product in list {
//            if (NSURL(string: product.productIdentifier)?.lastPathComponent == "\(credits)") {
//                p = product
//                buyProduct()
//            }
//        }
//    }
//    func addCredits(credits:Int) {
//        Settings().availableCredits += credits
//    }
//    var list = [SKProduct]()
//    var p = SKProduct()
//    // iap.addCredits
//    func buyProduct() {
//        print("buy " + p.productIdentifier)
//        let pay = SKPayment(product: p)
//        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
//        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
//    }
//    //MARK: - SKPaymentTransactionObserver
//    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
//        print("transactions restored")
//        //var purchasedItemIDS = []
//        for transaction in queue.transactions {
//            let t: SKPaymentTransaction = transaction 
//            let prodID = t.payment.productIdentifier as String
//            switch prodID {
//            case "com.garthmackenzie.PaddleBallA52.addCredits.10":
//                print("add 10 credits to account")
//                addCredits(10)
//            case "com.garthmackenzie.PaddleBallA52.addCredits.40":
//                print("add 40 credits to account")
//                addCredits(40)
//            case "com.garthmackenzie.PaddleBallA52.addCredits.70":
//                print("add 70 credits to account")
//                addCredits(70)
//            case "com.garthmackenzie.PaddleBallA52.addCredits.150":
//                print("add 150 credits to account")
//                addCredits(150)
//            case "com.garthmackenzie.PaddleBallA52.addCredits.350":
//                print("add 350 credits to account")
//                addCredits(350)
//            case "com.garthmackenzie.PaddleBallA52.addCredits.1000":
//                print("add 1000 credits to account")
//                addCredits(1000)
//            case "com.garthmackenzie.PaddleBallA52.addCredits.2500":
//                print("add 2500 credits to account")
//                addCredits(2500)
//            default:
//                print("IAP not setup")
//            }
//        }
//    }
//    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        print("add paymnet")
//        for transaction:AnyObject in transactions {
//            let trans = transaction as! SKPaymentTransaction
//            print(trans.error)
//            switch trans.transactionState {
//            case .Purchased:
//                print("buy, ok unlock iap here")
//                print(p.productIdentifier)
//                let prodID = p.productIdentifier as String
//                switch prodID {
//                case "com.garthmackenzie.PaddleBallA52.addCredits.10":
//                    print("add 10 credits to account")
//                    addCredits(10)
//                case "com.garthmackenzie.PaddleBallA52.addCredits.40":
//                    print("add 40 credits to account")
//                    addCredits(40)
//                case "com.garthmackenzie.PaddleBallA52.addCredits.70":
//                    print("add 70 credits to account")
//                    addCredits(70)
//                case "com.garthmackenzie.PaddleBallA52.addCredits.150":
//                    print("add 150 credits to account")
//                    addCredits(150)
//                case "com.garthmackenzie.PaddleBallA52.addCredits.350":
//                    print("add 350 credits to account")
//                    addCredits(350)
//                case "com.garthmackenzie.PaddleBallA52.addCredits.1000":
//                    print("add 1000 credits to account")
//                    addCredits(1000)
//                case "com.garthmackenzie.PaddleBallA52.addCredits.2500":
//                    print("add 2500 credits to account")
//                    addCredits(2500)
//                default:
//                    print("IAP not setup")
//                }
//                queue.finishTransaction(trans)
//                break;
//            case .Failed:
//                print("buy error")
//                queue.finishTransaction(trans)
//                break;
//            default:
//                print("default")
//                break;
//            }
//        }
//    }
//    func finishTransaction(trans:SKPaymentTransaction) {
//        print("finishTransaction")
//        SKPaymentQueue.defaultQueue().finishTransaction(trans)
//    }
//    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
//        print("removedTransactions");
//    }
//
//}